From: Steven French <sfrench@us.ibm.com>
Subject: Re: CIFS regression in 2.6.27.8
Date: Mon, 8 Dec 2008 15:10:35 -0600
Message-ID: <OF3E80A64B.F15C9D0B-ON87257519.00745117-86257519.0074700A@us.ibm.com>
References: <493D8A8B.9090201@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Dennis Hardy <dhardy@sogetthis.com>, Greg KH <gregkh@suse.de>,
	Holger Hoffstaette <holger@wizards.de>, layton@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753519AbYLHVK5@vger.kernel.org>
In-Reply-To: <493D8A8B.9090201@s5r6.in-berlin.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yes - they look distinct


Steve French
Senior Software Engineer
Linux Technology Center - IBM Austin
phone: 512-838-2294
email: sfrench at-sign us dot ibm dot com



Stefan Richter <stefanr@s5r6.in-berlin.de> 
12/08/2008 02:58 PM

To
"Rafael J. Wysocki" <rjw@sisk.pl>
cc
Pekka Enberg <penberg@cs.helsinki.fi>, Dennis Hardy 
<dhardy@sogetthis.com>, linux-kernel@vger.kernel.org, layton@redhat.com, 
Steven French/Austin/IBM@IBMUS, Greg KH <gregkh@suse.de>, 
netdev@vger.kernel.org, Holger Hoffstaette <holger@wizards.de>
Subject
Re: CIFS regression in 2.6.27.8






Rafael J. Wysocki wrote:
>> On Mon, Dec 8, 2008 at 8:18 PM, Dennis Hardy <dhardy@sogetthis.com> 
wrote:
>>> I just mounted a network drive (Windows Server) via CIFS under 
2.6.27.8, and
>>> the sizes reported by "df" are completely incorrect:
...
>>> Does anyone else see this sort of behavior with 2.6.27.8?  This worked 
fine
>>> in 2.6.27.6 (we skipped 2.6.27.7)...

There were several cifs updates in .8 but AFAIU none in .7.

> FWIW, it seems to be related to this one: 
http://lkml.org/lkml/2008/12/8/7

Holger's report is about the userland SMB/CIFS server, while Denis's is
about kernelspace client code.  They look like separate issues to me.
-- 
Stefan Richter
-=====-==--- ==-- -=---
http://arcgraph.de/sr/
