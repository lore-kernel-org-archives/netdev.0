From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 9816] New: cannot replace route
Date: Sat, 26 Jan 2008 00:11:57 +0100
Message-ID: <479A6CBD.4010908@gmail.com>
References: <bug-9816-10286@http.bugzilla.kernel.org/> <20080125142603.a73fd7a2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Joonwoo Park <joonwpark81@gmail.com>,
	bugme-daemon@bugzilla.kernel.org, schwab@suse.de
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:13379 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761404AbYAYXJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 18:09:27 -0500
Received: by ug-out-1314.google.com with SMTP id z38so596771ugc.16
        for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 15:09:26 -0800 (PST)
In-Reply-To: <20080125142603.a73fd7a2.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote, On 01/25/2008 11:26 PM:

>> On Fri, 25 Jan 2008 13:23:49 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:
>> http://bugzilla.kernel.org/show_bug.cgi?id=9816

...

> I'd agree with Andrea: replacing a route with itself a) used to work and b)
> should still work (surely)?

...on the other hand:

$ touch file1
$ cp file1 file1
cp: `file1' and `file1' are the same file
$ mv file1 file1
mv: `file1' and `file1' are the same file

and: 'everything' in 'linux' is file...

ergo: route cannot replace with itself!

Regards,
Jarek P.
