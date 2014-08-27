From: Cong Wang <cwang@twopensource.com>
Subject: Re: [patch net-next RFC 03/12] net: introduce generic switch devices support
Date: Wed, 27 Aug 2014 15:19:12 -0700
Message-ID: <CAHA+R7NGtF5ybeOU5pJrqpyS3u8EeC7xomoAHyBa7Ze8pBeJyA@mail.gmail.com>
References: <1408637945-10390-1-git-send-email-jiri@resnulli.us>
	<1408637945-10390-4-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <dborkman@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>, azhou@nicira.com,
	Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	Cong Wang <xiyou.wangcong@gmail.com>,
	john.r.fastabend@intel.com, Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org, jasowang@redhat.com,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	ryazanov.s.a@gma
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:35723 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932246AbaH0WTO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 18:19:14 -0400
Received: by mail-lb0-f181.google.com with SMTP id n15so85104lbi.26
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 15:19:12 -0700 (PDT)
In-Reply-To: <1408637945-10390-4-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2014 at 9:18 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> diff --git a/include/linux/switchdev.h b/include/linux/switchdev.h
> new file mode 100644
> index 0000000..ba77a68
> --- /dev/null
> +++ b/include/linux/switchdev.h

It should be in include/net/ instead, since it never
goes out of networking.
