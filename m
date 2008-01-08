From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Top 10 kernel oopses for the week ending January 5th, 2008
Date: Tue, 8 Jan 2008 08:33:59 +0100
Message-ID: <20080108073359.GA1920@ff.dom.local>
References: <20080108055917.GZ27894@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Kevin Winchester <kjwinchester@gmail.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>, gregkh@suse.de, neilb@suse.de
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.186]:65408 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753444AbYAHH15 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 02:27:57 -0500
Received: by fk-out-0910.google.com with SMTP id z23so8969476fkz.5
        for <netdev@vger.kernel.org>; Mon, 07 Jan 2008 23:27:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080108055917.GZ27894@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08-01-2008 06:59, Al Viro wrote:
> On Mon, Jan 07, 2008 at 07:26:12PM -0800, Linus Torvalds wrote:
>  
>> I usually just compile a small program like
>>
>> 	const char array[]="\xnn\xnn\xnn...";
>>
>> 	int main(int argc, char **argv)
>> 	{
>> 		printf("%p\n", array);
>> 		*(int *)0=0;
>> 	}
> Heh.  I prefer
> char main[] = {.....};
> for the same thing, with gdb a.out and no running at all.
...

IMHO, it would be really wasteful if Arian havn't published these
and maybe a few more such advices and links on this site, not
necessarily waiting for html-ized or howto-ized versions!

Thanks,
Jarek P.
