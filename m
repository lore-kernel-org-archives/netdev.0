From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v3] rocker: add debugfs support to dump internal
 tables
Date: Tue, 18 Aug 2015 20:19:30 +0200
Message-ID: <20150818181930.GK4381@lunn.ch>
References: <1439850977-31079-1-git-send-email-sfeldma@gmail.com>
 <20150818140156.GE4381@lunn.ch>
 <CAE4R7bAwuZkoOqO1eA9pWQ35UPiSs7-Fm+AaedVU1wwiRZ=Jwg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	=?iso-8859-1?B?Smk/P+0gUO1ya28=?= <jiri@resnulli.us>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:33127 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753994AbbHRS0s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 14:26:48 -0400
Content-Disposition: inline
In-Reply-To: <CAE4R7bAwuZkoOqO1eA9pWQ35UPiSs7-Fm+AaedVU1wwiRZ=Jwg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 18, 2015 at 10:18:51AM -0700, Scott Feldman wrote:
> On Tue, Aug 18, 2015 at 7:01 AM, Andrew Lunn <andrew@lunn.ch> wrote:
> > On Mon, Aug 17, 2015 at 03:36:17PM -0700, sfeldma@gmail.com wrote:
> >> From: Scott Feldman <sfeldma@gmail.com>
> >>
> >> > tree /sys/kernel/debug/rocker
> >> /sys/kernel/debug/rocker
> >> ????????? 5254001235010000
> >>     ????????? fdb_tbl
> >>     ????????? internal_vlan_tbl
> >>     ????????? neigh_tbl
> >>     ????????? of_dpa_flow_tbl
> >>     ????????? of_dpa_group_tbl
> >>
> >> 1 directory, 5 files
> >>
> >> > cat /sys/kernel/debug/rocker/5254001235010000/internal_vlan_tbl
> >> ifindex 5 ref_count 1 vlan 3843
> >> ifindex 7 ref_count 2 vlan 3840
> >> ifindex 4 ref_count 1 vlan 3842
> >>
> >> > cat /sys/kernel/debug/rocker/5254001235010000/fdb_tbl
> >> learned 1 pport 1 addr 00:02:00:00:02:00 vlan 3840
> >> learned 1 pport 2 addr 00:02:00:00:03:00 vlan 3840
> >>
> >> > cat /sys/kernel/debug/rocker/5254001235010000/neigh_tbl
> >> 11.0.0.9 dev sw1p2 ref_count 3 index 1 dst 00:02:00:00:01:00 ttl_check 1
> >> 11.0.0.1 dev sw1p1 ref_count 3 index 0 dst 00:02:00:00:00:00 ttl_check 1
> >
> > Hi Scott
> >
> > David is not so keen no debugfs stuff. He already NACKed adding more
> > than what is currently in DSA:
> >
> > https://lkml.org/lkml/2015/7/11/8
> 
> That patch added writable debugfs files, which I can see might be used
> as a back-door to program hardware.  That does seem bad.

I fully agreed with respect to write. But if you read the whole
message, David is also not happy with read only.

I think before you spend too much more time on this, you need some
indication from David if he is going to merge it or not.

   Andrew
