From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [ANNOUNCE]: Release of iptables-1.4.4
Date: Tue, 16 Jun 2009 16:36:43 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0906161635060.3418@fbirervta.pbzchgretzou.qr>
References: <4A3787DB.1040704@trash.net> <x6ski01g7t@gzp> <4A379FC2.7060004@trash.net> <alpine.LSU.2.00.0906161629360.3418@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Gabor Z. Papp" <gzp@papp.hu>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"'netfilter@vger.kernel.org'" <netfilter@vger.kernel.org>,
	netfilter-announce@lists.netfilter.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:34618 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442AbZFPOgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 10:36:41 -0400
In-Reply-To: <alpine.LSU.2.00.0906161629360.3418@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tuesday 2009-06-16 16:30, Jan Engelhardt wrote:
>On Tuesday 2009-06-16 15:36, Patrick McHardy wrote:
>> Gabor Z. Papp wrote:
>>> * Patrick McHardy <kaber@trash.net>:
>>>
>>> | The netfilter coreteam presents:
>>> |     iptables version 1.4.4
>>>
>>> config.h:#define PACKAGE_VERSION "1.4.3.2"
>>
>> Run configure.
>
>Nope, see `git show v1.4.4:configure.ac`.
>AC_INIT in configure.ac was indeed not updated.

In other words: tagging a revision alone won't do it. Similarly
to the Linux kernel, a specific version bump commit like
07a2039b8eb0af4ff464efd3dfd95de5c02648c6 is needed which is then
tagged.
