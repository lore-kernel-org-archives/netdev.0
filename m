From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9816] New: cannot replace route
Date: Fri, 25 Jan 2008 19:20:26 -0800
Message-ID: <20080125192026.e667f396.akpm@linux-foundation.org>
References: <bug-9816-10286@http.bugzilla.kernel.org/>
	<20080125142603.a73fd7a2.akpm@linux-foundation.org>
	<479A6CBD.4010908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joonwpark81@gmail.com,
	bugme-daemon@bugzilla.kernel.org, schwab@suse.de
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:59573 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754251AbYAZDUb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 22:20:31 -0500
In-Reply-To: <479A6CBD.4010908@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Sat, 26 Jan 2008 00:11:57 +0100 Jarek Poplawski <jarkao2@gmail.com> wrote:
> Andrew Morton wrote, On 01/25/2008 11:26 PM:
> 
> >> On Fri, 25 Jan 2008 13:23:49 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:
> >> http://bugzilla.kernel.org/show_bug.cgi?id=9816
> 
> ...
> 
> > I'd agree with Andrea: replacing a route with itself a) used to work and b)
> > should still work (surely)?
> 
> ...on the other hand:
> 
> $ touch file1
> $ cp file1 file1
> cp: `file1' and `file1' are the same file
> $ mv file1 file1
> mv: `file1' and `file1' are the same file
> 
> and: 'everything' in 'linux' is file...
> 
> ergo: route cannot replace with itself!
> 

That's not a very good analogy - the source is a kernel object.  A better
example would be:

linux-2.6.24-rc8:

echo foo > /tmp/1
echo bar > /tmp/2
echo foo > /tmp/1

linux-2.6.24:

echo foo > /tmp/1
echo bar > /tmp/2
echo foo > /tmp/1
sh: cannot write /tmp/1: Inalid argument

But whatever.   It used to work.  People's scripts will break.  Regression.
