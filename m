From: Gertjan van Wingerde <gwingerde@home.nl>
Subject: Re: [RFC] Wireless extensions rethink
Date: Thu, 17 Jun 2004 20:30:40 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D1E350.6030509@home.nl>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0103AF626C@orsmsx402.amr.corp.intel.com> <40CF263E.70009@home.nl> <1087377197.25912.54.camel@sfeldma-mobl2.dsl-verizon.net> <40D08769.3070106@home.nl> <20040616204248.GA23617@bougret.hpl.hp.com> <40D0BD5B.201@pobox.com> <20040616223316.GA29618@bougret.hpl.hp.com> <40D0D265.3070804@pobox.com> <20040617174717.GA30460@bougret.hpl.hp.com> <40D1E185.2010201@pobox.com> <40D1E24C.8090802@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jt@hpl.hp.com, sfeldma@pobox.com, jkmaline@cc.hut.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <40D1E24C.8090802@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff,

I think I get the gist of it. I'll start working on this and produce some results in a few days.
We can then review the results start discussing further directions/modifications.

I'll leave netlink out of it right now (see the problems Jean had earlier), but I think that the
basic approach (wireless_ops, etc.) can be reused within a netlink implementation anyway.

--- Gertjan.


Jeff Garzik wrote:
> Jeff Garzik wrote:
> 
>> struct wireless_ops {
>>     int (*get_name) (struct net_device *dev, struct iw_request_info 
>> *info,
>>                            union iwreq_data *wrqu, char *extra);
>>     int (*get_freq) (struct net_device *dev, struct iw_request_info 
>> *info,
>>                                union iwreq_data *wrqu, char *extra);
>>     int (*set_freq) (struct net_device *dev, struct iw_request_info 
>> *info,
>>                            union iwreq_data *wrqu, char *extra);
>>     int (*get_mode) (struct net_device *dev, struct iw_request_info 
>> *info,
>>                            union iwreq_data *wrqu, char *extra);
>>     int (*set_mode) (struct net_device *dev, struct iw_request_info 
>> *info,
>>                            union iwreq_data *wrqu, char *extra);
> 
> 
> 
> Note that the above is only a first step.  Through the standard Linux 
> development process -- evolution -- each hook can be pared down to 
> precisely what each call needs.  The above allows for a quick transition 
> of drivers, while keeping them working.
> 
>     Jeff
> 
> 
> 
