From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] Netlink and user-space buffer pointers
Date: Wed, 19 Apr 2006 19:16:10 +0200
Message-ID: <4446705A.2080101@trash.net>
References: <1145306661.4151.0.camel@localhost.localdomain> <20060418160121.GA2707@us.ibm.com> <444633B5.5030208@emulex.com> <444663A9.9020502@trash.net> <44466EA7.3030206@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
To: James.Smart@Emulex.Com
In-Reply-To: <44466EA7.3030206@emulex.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Smart wrote:
> 
> 
> Patrick McHardy wrote:
> 
>> This might be problematic, since there is a shared receive-queue in
>> the kernel netlink message might get processed in the context of
>> a different process. I didn't find any spots where ISCSI passes
>> pointers over netlink, can you point me to it?
> 
> 
> Please explain... Would the pid be set erroneously as well ?  Ignoring
> the kernel-user space pointer issue, we're going to have a tight
> pid + request_id relationship being maintained across multiple messages.
> We'll also be depending on the pid events for clean up if an app dies.
> So I hope pid is consistent.

The PID contained in the netlink message itself is correct, current->pid
might not be.
