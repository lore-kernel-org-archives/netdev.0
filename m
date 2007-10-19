From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: 2.6.23-mm1 s390 driver problem
Date: Fri, 19 Oct 2007 13:06:19 +0200
Message-ID: <47188FAB.70203@fr.ibm.com>
References: <20071018200148.GA14234@vino.hallyn.com>
	<200710182215.56428.borntraeger@de.ibm.com>
	<20071018203151.GA15382@vino.hallyn.com>
	<1192780036.25150.7.camel@localhost> <471875E0.8040308@fr.ibm.com>
	<1192785653.25150.9.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
        cornelia.huck-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
        sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org, "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
To: schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1192785653.25150.9.camel@localhost>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Martin Schwidefsky wrote:
> On Fri, 2007-10-19 at 11:16 +0200, Cedric Le Goater wrote:
>>> This is the vmlinux.lds.S problem. The cleanup patch from Sam Ravnborg
>>> moved the __initramfs_start and __initramfs_end symbols into
>>> the .init.ramfs section. This is in itself not a problem, but it
>>> surfaced a bug: there is no *(.init.initramfs), that needs to be
>>> *(init.ramfs). I corrected this in the upstream patch but 2.6.23-mm1 has
>>> the older one that still causes the "Cannot open root device". For
>>> 2.6.23-mm1 use the patch below.
>>>
>> thanks martin, 
>>
>> that helped going a little further in the boot process but we then have 
>> a network issue when bringing the network interface up :
> 
> See http://marc.info/?l=linux-kernel&m=119270398931208&w=2

hmm, that doesn't fix the oops.

/me looking.

Thanks,

C.
