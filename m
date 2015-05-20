From: Andy Grover <agrover-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH 0/4] Make iSCSI network namespace aware
Date: Wed, 20 May 2015 11:45:43 -0700
Message-ID: <555CD657.6080004@redhat.com>
References: <1431555167-23995-1-git-send-email-cleech@redhat.com>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <open-iscsi+bncBD7KBJUK5QPBBWNM6OVAKGQESSIJQWY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1431555167-23995-1-git-send-email-cleech-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Post: <http://groups.google.com/group/open-iscsi/post>, <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/open-iscsi
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/open-iscsi/subscribe>, <mailto:open-iscsi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+856124926423+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <http://groups.google.com/group/open-iscsi/subscribe>
List-Id: netdev.vger.kernel.org

On 05/13/2015 03:12 PM, Chris Leech wrote:
> This is only about the structures and functionality involved in maintaining the
> iSCSI session, the SCSI host along with it's discovered targets and devices has
> no association with network namespaces.
>
> These patches are functional, but not complete.  There's no isolation enforced
> in the kernel just yet, so it relies on well behaved userspace.  I plan on
> fixing that, but wanted some feedback on the idea and approach so far.

Seems like a good direction, to me.

What would be the extent of the userspace (open-iscsi) changes needed to 
go along with this?

Regards -- Andy

-- 
You received this message because you are subscribed to the Google Groups "open-iscsi" group.
To unsubscribe from this group and stop receiving emails from it, send an email to open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
Visit this group at http://groups.google.com/group/open-iscsi.
For more options, visit https://groups.google.com/d/optout.
