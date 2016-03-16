From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net-next 5/6] bridge: a netlink notification should be
 sent when those attributes are changed by br_sysfs_if
Date: Wed, 16 Mar 2016 22:49:02 +0800
Message-ID: <CADvbK_d=Vyxk027bdYJ1vQejQSHfTvgqmC2yp3hoOu_egG=aHw@mail.gmail.com>
References: <cover.1458134414.git.lucien.xin@gmail.com>
	<059d608901fd86407fed374e567c46447aa8c88f.1458134414.git.lucien.xin@gmail.com>
	<f379a033c5b7798906c57dd1bb67df89b7de02cb.1458134414.git.lucien.xin@gmail.com>
	<45f430c026ce8a2fb358c650a41452aebff9ec36.1458134414.git.lucien.xin@gmail.com>
	<38a10eecc6347a3c47b55c86b4783c49b6dbbc99.1458134414.git.lucien.xin@gmail.com>
	<7c788b65786582209a3ba4bc4d4ed279f6f77568.1458134414.git.lucien.xin@gmail.com>
	<56E96C4C.8060407@cumulusnetworks.com>
	<CADvbK_eZUKV21x241heK45D9j62Fg7fZqd5rgG-S_LPed2WGjw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, davem <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f193.google.com ([209.85.214.193]:36478 "EHLO
	mail-ob0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933471AbcCPOtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 10:49:03 -0400
Received: by mail-ob0-f193.google.com with SMTP id cf7so3388116obc.3
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 07:49:02 -0700 (PDT)
In-Reply-To: <CADvbK_eZUKV21x241heK45D9j62Fg7fZqd5rgG-S_LPed2WGjw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 16, 2016 at 10:45 PM, Xin Long <lucien.xin@gmail.com> wrote:
> yeah, because port fdb_flush is called by brport_store(), in the
> common function.
> do you think it''s redundant if we add a notification in bridge
> fdb_flush to keep
> consistence with port fdb_flush?
just change it on patch 1/6.
