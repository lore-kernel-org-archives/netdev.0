From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: private netdev flags into UAPI?
Date: Tue, 27 Nov 2012 08:51:28 +0200
Message-ID: <50B462F0.1070506@mellanox.com>
References: <CAJZOPZLQSCNTfSm63z1P_S4ZmwL+9mbP7rOCH7yHgBFcjaz1UA@mail.gmail.com> <50B1CC1B.20104@mellanox.com> <10845.1353921761@warthog.procyon.org.uk> <990.1353981789@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <or.gerlitz@gmail.com>, netdev <netdev@vger.kernel.org>
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:58023 "HELO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757842Ab2K0Gxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 01:53:45 -0500
In-Reply-To: <990.1353981789@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/11/2012 04:03, David Howells wrote:
> Or Gerlitz <or.gerlitz@gmail.com> wrote:
>
>> On Mon, Nov 26, 2012 at 11:22 AM, David Howells <dhowells@redhat.com> wrote:
>>> They were exposed to userspace already
>> So the script carries the bug into a new directory... why? AFAIK,
>> intentionally there's no way to read private flags from user space, so
>> what's the point in defining them there?
> How should the script know what's private and what's not?  By the
> encapsulation of code inside __KERNEL__ blocks.  In their absence, everything
> is assumed to be public - given it is already part of the UAPI.  I don't know
> that the code is private rather than the comment is wrong.
>
>

makes sense, but I have pointed on a bug in the final result, so this 
way or another, the fact that the bug
existed before doesn't mean we should carry it over.

Or.
