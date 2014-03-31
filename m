From: Neil Jerram <Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org>
Subject: Re: [patch net-next RFC v2 4/6] net: introduce switchdev
	API
Date: Mon, 31 Mar 2014 20:55:01 +0000
Message-ID: <F6885DC5CBE92C4BB4D654841E63A30FD7DFC924@ENFIRHMBX1.datcon.co.uk>
References: <1395851472-10524-1-git-send-email-jiri@resnulli.us>
 <1395851472-10524-5-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
 "edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org" <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
 "andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org" <andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org>,
 "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 "f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 "jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
 "ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
 "ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org" <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
 "roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org" <roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>,
 "jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org" <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
 "linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
 "vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 "nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org" <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
 "sfeldma-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org" <sfeldma-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>,
 "stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org" <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
 "dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: 'Jiri Pirko' <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>, "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org"
 <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1395851472-10524-5-git-send-email-jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

Hi Jiri,

Apologies for possibly newbie questions here, but:

> +bool swdev_dev_check(const struct net_device *dev)
> +{
> +	return dev->priv_flags & IFF_SWITCH;
> +}
> +EXPORT_SYMBOL(swdev_dev_check);
[...]
> +	BUG_ON(!swdev_dev_check(dev));
[...]
> +int __swdev_register(struct net_device *dev)
> +{
> +	if (dev->priv_flags & IFF_SWITCH) {
> +		netdev_err(dev, "Device is already registered as a switch
> device\n");
> +		return -EBUSY;
> +	}
[...]

1. What's the benefit of requiring and policing the IFF_SWITCH flag, and requiring a switch netdev to call swdev_register, as opposed to just checking whether the netdev provides the relevant ops?

> +int swdev_register(struct net_device *dev)
> +{
> +	int err;
> +
> +	rtnl_lock();
> +	err = __swdev_register(dev);
> +	rtnl_unlock();
> +	return err;
> +}
> +EXPORT_SYMBOL(swdev_register);

2. Why grab and release the rtnl lock, given that there appears to be nothing rtnl-related in between?

Regards,
	Neil
