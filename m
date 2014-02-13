From: Ilia Mirkin <imirkin@alum.mit.edu>
Subject: ip_set: protocol %u message -- useful?
Date: Thu, 13 Feb 2014 04:30:42 -0500
Message-ID: <CAKb7UvhsLi2Sv4SWA2nVTgoFV8dzrY=3R1-SUk9D-aa0VdizSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Patrick McHardy <kaber@trash.net>, Vitaly Lavrov <lve@guap.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I've recently noticed a lot of

[356872.380595] ip_set: protocol 6

messages in my dmesg. This might be because of some local
configuration changes I've made, or perhaps a kernel upgrade. Either
way, it appears this message has been a pr_notice since the original
code added it in a7b4f989a62 ("netfilter: ipset: IP set core
support").

Does this message provide a lot of value? Or could it be made into a pr_debug?

FWIW commit 1785e8f473 ("netfiler: ipset: Add net namespace for
ipset"), merged in v3.13-rc1 changed the code around which may have
made it more likely to appear in dmesg (with the namespace stuff). Not
sure though. I don't (purposely) use namespaces.

I'm happy to put together a patch demoting it to pr_debug if people
think it's OK.

Thanks,

  -ilia
