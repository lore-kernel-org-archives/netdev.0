From: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH for-next 01/10] net/core: Add support for configuring VF GUIDs
Date: Mon, 7 Mar 2016 09:23:28 +0200
Message-ID: <CAJ3xEMhAZPajXLizotmAFDymG9d06-BVGFSnNDiDKO4SP8BuRg@mail.gmail.com>
References: <1456851143-138332-1-git-send-email-eli@mellanox.com>
	<1456851143-138332-2-git-send-email-eli@mellanox.com>
	<20160301173751.GA25176@obsidianresearch.com>
	<20160301174951.GA19366@x-vnc01.mtx.labs.mlnx>
	<20160301182516.GA12495@obsidianresearch.com>
	<CAJ3xEMgrAUCj7PS6fegmuSUsjMruH3gzSHZmuzAX+ZbHZOpL9w@mail.gmail.com>
	<56D719E3.2000206@redhat.com>
	<CAJ3xEMh5vJAZVO03=rRVCvqqXzXvah3idrMtMQfFP-wBxR7R_Q@mail.gmail.com>
	<56D99D3D.4000606@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <56D99D3D.4000606-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 4, 2016 at 4:35 PM, Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:

[...]
> So, at *best*, the solution you are suggesting for existing setups is a
> partial solution that leaves things only half done.
[...]

Doug,

Point/s taken, justifying the code re-route of libvirt attempting to
issue set_vf_mac on the PF to go through
set_vf_guid needs handling of more aspects. We will remove it from this patch.

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
