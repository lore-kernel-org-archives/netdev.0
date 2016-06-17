From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [iproute PATCH 1/3] Use C99 style initializers everywhere
Date: Fri, 17 Jun 2016 18:58:14 +0200
Message-ID: <57642C26.6060105@6wind.com>
References: <1466178968-27439-1-git-send-email-phil@nwl.cc>
 <1466178968-27439-2-git-send-email-phil@nwl.cc>
 <ddef688e6e3f4a1a895880de1f9f069d@HQ1WP-EXMB11.corp.brocade.com>
 <20160617093401.24ae66b1@xeon-e3> <5764295E.7070103@iogearbox.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Phil Sutter <phil@nwl.cc>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	julien.floret@6wind.com
To: Daniel Borkmann <daniel@iogearbox.net>,
	Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:38455 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751AbcFQQ6S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 12:58:18 -0400
Received: by mail-wm0-f48.google.com with SMTP id m124so7565287wme.1
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 09:58:17 -0700 (PDT)
In-Reply-To: <5764295E.7070103@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 17/06/2016 18:46, Daniel Borkmann a =E9crit :
> On 06/17/2016 06:34 PM, Stephen Hemminger wrote:
>> On Fri, 17 Jun 2016 16:09:20 +0000
>> Daniel Borkmann <daniel@iogearbox.net> wrote:
>>
>>> Please have a look at commit 8f80d450c3cb ("tc: fix compilation wit=
h old gcc
>>> (< 4.6)") ...
>>>
>>> Your changes effectively revert them again. Here, and some other pa=
rts of the
>>> bpf frontend
>>> code bits.
>>
>> GCC 4.6 is 3 years old. So perhaps it is time to move on.
>> Maybe add a GCC version check in the makefile, to fail cleanly.
>=20
> Well, you don't have to ask me but rather the patch submitters (Cc).
>=20
> I haven't used RHEL in quite a while, but I could imagine it might
> be related to built it there perhaps.
Yes. For some specific arch, we have only old toolchains.

The rule was always to be backward compatible with old kernels. It impl=
ies to
also support the compilation with old toolchains ;-)
