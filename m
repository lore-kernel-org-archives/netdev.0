From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 00/13] introduce rocker switch driver with
 openvswitch hardware accelerated datapath
Date: Tue, 16 Sep 2014 17:58:32 +0200
Message-ID: <20140916155832.GA1869@nanopsycho.orion>
References: <1409736300-12303-1-git-send-email-jiri@resnulli.us>
 <20140908135413.GA5995@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@cumulusnetworks.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:33285 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754323AbaIPP6f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 11:58:35 -0400
Received: by mail-wi0-f175.google.com with SMTP id cc10so6602924wib.8
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 08:58:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140908135413.GA5995@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Sep 08, 2014 at 03:54:13PM CEST, tgraf@suug.ch wrote:
>On 09/03/14 at 11:24am, Jiri Pirko wrote:
>> This patchset can be divided into 3 main sections:
>> - introduce switchdev api for implementing switch drivers
>> - add hardware acceleration bits into openvswitch datapath, This uses
>>   previously mentioned switchdev api
>> - introduce rocker switch driver which implements switchdev api
>
>Jiri, Scott,
>
>Enclosed is the GOOG doc which outlines some details on my particular
>interests [0]. It includes several diagrams which might help to
>understand the overall arch. It is highly related to John's work as
>well. Please let me know if something does not align with the model
>you have in mind.


Hi Thomas.

Sorry for late answer, I returned from vacation yesterday.
I went over your document, I did not find anything which would not align
with our approach. Looks good to me.

>
>Summary:
>The full virtual tunnel endpoint flow offload attempts to offload full
>flows to the hardware and utilize the embedded switch on the host NIC
>to empower the eSwitch with the required flexibility of the software
>driven network. In this model, the guest (VM or LXC) attaches through a
>SR-IOV VF which serves as the primary path. A slow path / software path
>is provided via the CPU which can route packets back into the VF by
>tagging packets with forwarding metadata and sending the frame back to
>the NIC.
>
>[0] https://docs.google.com/document/d/195waUliu7G5YYVuXHmLmHgJ38DFSte321WPq0oaFhyU/edit?usp=sharing
>(Publicly accessible and open for comments)
