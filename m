From: Michel Alexandre Salim <salimma@fedoraproject.org>
Subject: Re: [Bugme-new] [Bug 41312] New: Regression: some web services (e.g.
 Dropbox, Amazon Cloud Reader) stops working in 3.1-rc2
Date: Thu, 18 Aug 2011 12:26:51 +0200
Message-ID: <CALRZsj2p2_AVsJPFucwuYy25YTODnfTcnNqBsuQBURK=w+xJVQ@mail.gmail.com>
References: <bug-41312-10286@https.bugzilla.kernel.org/> <20110817134106.015135cd.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:36485 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752825Ab1HRK1M convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2011 06:27:12 -0400
Received: by yie30 with SMTP id 30so1364818yie.19
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2011 03:27:11 -0700 (PDT)
In-Reply-To: <20110817134106.015135cd.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 17, 2011 at 10:41 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>
> (switched to email. =A0Please respond via emailed reply-to-all, not v=
ia the
> bugzilla web interface).
>

Replying via email; please let me know if there's any further tests I
can do. I forgot to add the system details: tested on

- Fedora 15 x86_64, wireless network (ath9k)
- Fedora 15 x86_64, wired network    (e1000e)


> On Wed, 17 Aug 2011 20:17:05 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
>
>> https://bugzilla.kernel.org/show_bug.cgi?id=3D41312
>>
>> =A0 =A0 =A0 =A0 =A0 =A0Summary: Regression: some web services (e.g. =
Dropbox, Amazon
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Cloud Reader) stops working =
in 3.1-rc2
>> =A0 =A0 =A0 =A0 =A0 =A0Product: Networking
>> =A0 =A0 =A0 =A0 =A0 =A0Version: 2.5
>> =A0 =A0 Kernel Version: 3.1-rc2
>> =A0 =A0 =A0 =A0 =A0 Platform: All
>> =A0 =A0 =A0 =A0 OS/Version: Linux
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 Tree: Mainline
>> =A0 =A0 =A0 =A0 =A0 =A0 Status: NEW
>> =A0 =A0 =A0 =A0 =A0 Severity: normal
>> =A0 =A0 =A0 =A0 =A0 Priority: P1
>> =A0 =A0 =A0 =A0 =A0Component: IPV4
>> =A0 =A0 =A0 =A0 AssignedTo: shemminger@linux-foundation.org
>> =A0 =A0 =A0 =A0 ReportedBy: salimma@fedoraproject.org
>> =A0 =A0 =A0 =A0 Regression: Yes
>>
>>
>> Created an attachment (id=3D69102)
>> =A0--> (https://bugzilla.kernel.org/attachment.cgi?id=3D69102)
>> (working) config for kernel 3.0
>>
>> Dropbox and Amazon Cloud Reader works just fine on kernel 3.0, but t=
he former
>> does not work on 3.1-rc1 and 3.1-rc2, and the latter does not work o=
n 3.1-rc2
>> (I no longer have a copy of the 3.1-rc1 build I did).
>>
>> With Dropbox, ps reports that the daemon process is in an uninterrup=
tible
>> state, and it cannot be killed (even with kill -9). Setting SELinux =
to
>> permissive does not affect things (and Dropbox works with SELinux se=
t to
>> enforcing with kernel 3.0).
>>
>> With Cloud Reader, on Chrome, it does not display any book -- I perp=
etually get
>> the "refreshing" icon.
>>
>> Will attach kernel configurations (I keep the 3.0 and 3.1-rc2 config=
s as
>> similar as possible, by using 'make oldconfig' on 3.0 with 3.1-rc2's=
 .config.
>>
>> Reported on Dropbox's forum: http://forums.dropbox.com/topic.php?id=3D=
43140
>>
>
>



--=20
Michel Alexandre Salim
=46edora Project Contributor: http://fedoraproject.org/

Email: =A0salimma@fedoraproject.org =A0| GPG key ID: 78884778
Jabber: hircus@jabber.ccc.de =A0 =A0 =A0 | IRC: hircus@irc.freenode.net

() =A0ascii ribbon campaign - against html e-mail
/\ =A0www.asciiribbon.org =A0 - against proprietary attachments
