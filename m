From: Michal Marek <mmarek@suse.com>
Subject: Re: [PATCH v2 8/8] treewide: Remove newlines inside DEFINE_PER_CPU()
 macros
Date: Mon, 7 Dec 2015 17:53:52 +0100
Message-ID: <5665B9A0.5060009@suse.com>
References: <1449242787-16598-1-git-send-email-mmarek@suse.com>
 <1449242787-16598-9-git-send-email-mmarek@suse.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CBE695F@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>,
	"rds-devel@oss.oracle.com" <rds-devel@oss.oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	"linux-kbuild@vger.kernel.org" <linux-kbuild@vger.kernel.org>
Return-path: <linux-ia64-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CBE695F@AcuExch.aculab.com>
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015-12-07 17:33, David Laight wrote:
> From: Michal Marek
>> Sent: 04 December 2015 15:26
>> Otherwise make tags can't parse them:
>>
>> ctags: Warning: arch/ia64/kernel/smp.c:60: null expansion of name pattern "\1"
> ...
> 
> Seems to me you need to fix ctags.

I'm sure the maintainers of ctags and etags would accept patches to
describe a custom context-free grammar via commandline options, but
until then, let's continue using the regular expressions in tags.sh and
remove newlines in macros that tags.sh is trying to expand.

Michal
