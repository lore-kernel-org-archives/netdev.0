From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 1/5] vxlan: Group Policy extension
Date: Wed, 14 Jan 2015 19:06:02 -0800
Message-ID: <CA+mtBx9QV89vb+kwY4PUnemwqq-vWgpU4paDEs0FjYVDS2MsXQ@mail.gmail.com>
References: <cover.1421290198.git.tgraf@suug.ch>
	<80677f296e829f43ca57a4c0dc4f45782e2e6f8e.1421290198.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:47119 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbbAODGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 22:06:03 -0500
Received: by mail-ig0-f171.google.com with SMTP id z20so25977181igj.4
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 19:06:02 -0800 (PST)
In-Reply-To: <80677f296e829f43ca57a4c0dc4f45782e2e6f8e.1421290198.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +struct vxlan_metadata {
> +       __be32          vni;
> +       u32             gbp;

Should this be __be32 also and use ntohl/htonl when setting to/from skb->mark?

> +};
> +
