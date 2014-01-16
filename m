From: =?windows-1252?Q?Jan_Kalu=9Ea?= <jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v4 0/3] Send audit/procinfo/cgroup data in socket-level
	control message
Date: Thu, 16 Jan 2014 10:29:51 +0100
Message-ID: <52D7A68F.5030700@redhat.com>
References: <1377614400-27122-1-git-send-email-jkaluza@redhat.com>
	<1389600109-30739-1-git-send-email-jkaluza@redhat.com>
	<20140115.121730.1984913330507219167.davem@davemloft.net>
	<1389828103.681.34.camel@flatline.rdu.redhat.com>
	<20140115232345.GA22237@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140115232345.GA22237-9pTldWuhBndy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/16/2014 12:23 AM, Tejun Heo wrote:
> On Wed, Jan 15, 2014 at 06:21:43PM -0500, Eric Paris wrote:
>> Reliably being able to audit what process requested an action is
>> extremely useful.  And I like the audit patch, as it is a couple of ints
>> we are storing.
>>
>> procinfo and cgroup can both be up to 4k of data.
>>
>> Is there an alternative he should consider?  Some way to grab a
>> reference on task_struct and just attach that to the message?
>
> Or maybe it can be made separately optional instead of tagging along
> on an existing option so that it doesn't tax use cases which don't
> care about the new stuff?

Right, I could add new option next to SOCK_PASSCRED which could be used 
to send newly added stuff. Would this be acceptable?

I would still vote for SCM_AUDIT to be part of SOCK_PASSCRED and move 
SCM_CGROUP and SCM_PROCINFO into new option.

> Thanks.
>

Regards,
Jan Kaluza
