From: Benoit Lourdelet <blourdel@juniper.net>
Subject: Re: [RFC][PATCH] iproute: Faster ip link add, set and delete
Date: Wed, 27 Mar 2013 13:37:45 +0000
Message-ID: <CD78B3C3.76D3%blourdel@juniper.net>
References: <20130326143321.GA21768@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Serge Hallyn <serge.hallyn@ubuntu.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og101.obsmtp.com ([64.18.2.155]:51423 "EHLO
	exprod7og101.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750798Ab3C0NjQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 09:39:16 -0400
Received: from mail89-co1 (localhost [127.0.0.1])	by mail89-co1-R.bigfish.com
 (Postfix) with ESMTP id 2C90768004B	for
 <netdev@vger.kernel.org.FOPE.CONNECTOR.OVERRIDE>; Wed, 27 Mar 2013 13:37:53
 +0000 (UTC)
In-Reply-To: <20130326143321.GA21768@sergelap>
Content-Language: en-US
Content-ID: <099C20A0B9A4E749B96D6DD1C3B6ABCC@namprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Serge,

I am indeed using Eric patch with lxc.

It solves the initial problem of slowness to start around 1600 containers.

I am now able to start more than  2000 without having new containers
slower and slower to start.

thanks

Benoit

On 26/03/2013 15:33, "Serge Hallyn" <serge.hallyn@ubuntu.com> wrote:

>Actually, lxc is using random names now, so it's ok.
>
>Benoit, can you use the patches from Eric with lxc (or use the script
>you were using before but specify names as he said)?
>
>-serge
>
