From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: e1000e crash with 82574L  2.6.37-0.rc5
Date: Tue, 21 Dec 2010 10:13:47 -0800
Message-ID: <EDC0E76513226749BFBC9C3FB031318F012396E558@orsmsx508.amr.corp.intel.com>
References: <128120.41188.qm@web39307.mail.mud.yahoo.com>
 <EDC0E76513226749BFBC9C3FB031318F01238645EB@orsmsx508.amr.corp.intel.com>
 <912683.73513.qm@web39308.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Brian Neu <proclivity76@yahoo.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:53421 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751045Ab0LUSOJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 13:14:09 -0500
In-Reply-To: <912683.73513.qm@web39308.mail.mud.yahoo.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: Brian Neu [mailto:proclivity76@yahoo.com]
>Sent: Monday, December 20, 2010 5:20 PM
>To: Wyborny, Carolyn; netdev@vger.kernel.org
>Cc: e1000-devel@lists.sourceforge.net
>Subject: Re: e1000e crash with 82574L 2.6.37-0.rc5
>
>> Hello,
>
>
>Thanks for responding.  I really wasn't sure where to report this.
>
>> We have some  known issues with 82574L but most have been resolved in
>the
>>latest versions, so  I'll need some more information.
>>
>> What version of e1000e are you using  exactly?  Are you able to
>download and
>>test the latest version of the  driver from SourceForge?
>
>
>This is the fedora build of kernel 2.6.37.0.rc5 which I downloaded from
>koji.fedoraproject.org.  I'm not sure which version of e1000e is
>included, but
>if I need to build a new module, just let me know.
>
>I had opened a bugzilla report with redhat which also has more
>backtraces:
> https://bugzilla.redhat.com/show_bug.cgi?id=625776
>
>> Please open an issue at SourceForge.net for easier  tracking of
>debugging
>>information.
>>
>> Please provide an output of lspci  -vvv.
>
>
>Attached.
>
>> What hw platform is this happening on?
>
>It's a Supermicro MB for AMD Socket G34
>
>> How often does it  happen and how long does it take to happen after
>reset or
>>reboot?
>
>It usually doesn't happen unless the system has been running for hours
>or days.
>
>>Is ASPM  enabled or disabled on your system.  Its possible to disable
>this in
>>the  BIOS, but not all BIOS provide the option.  If its enabled for
>some reason,
>>please disable it and try the driver  again.
>
>
>I'm going to check on this very soon and reply to the e1000 list only.

Hello Brian,

With this being a variant of Fedora, filing a Bugzilla was the right thing to do.  I missed that in your first email.

I checked your lspci output and ASPM *is* disabled as it should be.

When the adapter crashes/resets (per the log) does it come back up or stay down?

Since you're downloading off the Fedora build site, you could be encountering any number of things as these are live untested builds at this point.

Can you download a vanilla upstream build from kernel.org complete and see if the problem is happening there?  Or, you can download the latest released Fedora 14 from fedoraproject.org and see if the problem is happening with that build.  

Let me know how it goes,

Thanks,

Carolyn

Carolyn Wyborny
Linux Development
LAN Access Division
Intel Corporation

  
