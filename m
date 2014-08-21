From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next RFC 12/12] rocker: introduce rocker switch driver
Date: Thu, 21 Aug 2014 10:19:38 -0700
Message-ID: <CAGVrzcaWqqaYNJ2b8+mfV0tcgTMjgpWS01HJ4XvzduCzu_N13Q@mail.gmail.com>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us> <1408637945-10390-13-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>, tgraf <tgraf@suug.ch>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse <jesse@nicira.com>, pshelar <pshelar@nicira.com>,
	azhou <azhou@nicira.com>, Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>,
	dev <dev@openvswitch.org>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:38867 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752795AbaHURUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2014 13:20:19 -0400
Received: by mail-ie0-f179.google.com with SMTP id rl12so4892302iec.24
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2014 10:20:18 -0700 (PDT)
In-Reply-To: <1408637945-10390-13-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-08-21 9:19 GMT-07:00 Jiri Pirko <jiri@resnulli.us>:
> This patch introduces the first driver to benefit from the switchdev
> infrastructure and to implement newly introduced switch ndos. This is a
> driver for emulated switch chip implemented in qemu:
> https://github.com/sfeldma/qemu-rocker/
>
> This patch is a result of joint work with Scott Feldman.

You could eliminate a lot of boilerplate code that delegates
ethtool/netdev operations from the network interface to the switch
driver if you made this a DSA driver, without registering a tag
protocol or by reworking that.

Other than that, this is a really nice piece of driver you got here,
it's definitively a clean design. Thanks!
--
Florian
