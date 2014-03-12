From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [net-next 05/13] igb: Add support for debugfs
Date: Wed, 12 Mar 2014 17:57:40 +0200
Message-ID: <CAJZOPZ+TtFRjeA=9WZMhONSd65HZwMizf732W7oe-HJ=E0MBvg@mail.gmail.com>
References: <1394603618-1044-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1394603618-1044-6-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Josh Hay <hayja@mail.uc.edu>, Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <gospo@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:45915 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755193AbaCLP5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 11:57:41 -0400
Received: by mail-pd0-f173.google.com with SMTP id z10so1252420pdj.4
        for <netdev@vger.kernel.org>; Wed, 12 Mar 2014 08:57:40 -0700 (PDT)
In-Reply-To: <1394603618-1044-6-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 12, 2014 at 7:53 AM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> This patch adds the necessary defines, variables, and stats updating
> procedures to use the commands implemented in debugfs.

Guys,

Do we have a clear criteria when it makes sense to have debugfs for
network driver and when it doesn't, for example
we got this cold shower
http://marc.info/?l=linux-netdev&m=135959539719935&w=2 when attempting
to do so and I am
not fully clear (or want to sharpen the sow) how to review a concrete
design/need for debugs to fall into yes, it makes sense, or
no, it doesn't b/c there are existing mechanisms that can be used or
extended for that matter.

Or.
