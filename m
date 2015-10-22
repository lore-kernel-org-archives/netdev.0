From: Michal Marek <mmarek@suse.com>
Subject: Re: [PATCH 9/9] treewide: Remove newlines inside DEFINE_PER_CPU()
 macros
Date: Thu, 22 Oct 2015 14:24:14 +0200
Message-ID: <5628D56E.9080206@suse.com>
References: <1444940195-28272-1-git-send-email-mmarek@suse.com>
 <1444940195-28272-10-git-send-email-mmarek@suse.com>
 <5627E73B.9000502@redhat.com> <5627ED0D.20308@suse.com>
 <5628C913.10800@redhat.com> <5628D148.7000102@suse.com>
 <5628D332.9030304@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org, xen-devel@lists.xenproject.org,
	linux-acpi@vger.kernel.org, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org
To: Prarit Bhargava <prarit@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:46208 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756505AbbJVMYR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Oct 2015 08:24:17 -0400
In-Reply-To: <5628D332.9030304@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-10-22 14:14, Prarit Bhargava wrote:
> On 10/22/2015 08:06 AM, Michal Marek wrote:
>> It used to require a closing parenthesis, so it would not match the
>> multiline macro invocations at all. Now it matches them, but ctags
>> correctly warns that the empty string is probably not what we intended
>> to match.
> 
> It seems wrong to change kernel code, not for a bug, but for a userspace search.

The bug is that the code cannot be indexed using ctags or etags.

Michal
