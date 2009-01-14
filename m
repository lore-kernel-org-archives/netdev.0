From: Paul Menage <menage@google.com>
Subject: Re: [Devel] Re: [RFC][PATCH] IP address restricting cgroup subsystem
Date: Tue, 13 Jan 2009 18:50:29 -0800
Message-ID: <6599ad830901131850y508bbbbcr1560d762ed53d214@mail.gmail.com>
References: <20090106230554.GB25228@eskarina.localdomain.pl>
	 <49646993.6080802@cn.fujitsu.com> <20090107091600.GA17612@megiteam.pl>
	 <496476FD.8090209@cn.fujitsu.com>
	 <6599ad830901091338t38f5d5bav6adcd55ea188e28d@mail.gmail.com>
	 <49682921.4020100@cn.fujitsu.com>
	 <6599ad830901100814g5faeb611v7a36eed987c103ff@mail.gmail.com>
	 <496AA8E0.2070002@cn.fujitsu.com>
	 <6599ad830901131807n3acf6936g2028fc5f7edd6264@mail.gmail.com>
	 <496D524E.6050706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Grzegorz Nosek <root@localdomain.pl>, containers@lists.osdl.org,
	netdev@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:41600 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752672AbZANCuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 21:50:35 -0500
Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id n0E2oX5j007166
	for <netdev@vger.kernel.org>; Wed, 14 Jan 2009 02:50:33 GMT
Received: from rv-out-0708.google.com (rvbk29.prod.google.com [10.140.87.29])
	by zps76.corp.google.com with ESMTP id n0E2oU6t016604
	for <netdev@vger.kernel.org>; Tue, 13 Jan 2009 18:50:30 -0800
Received: by rv-out-0708.google.com with SMTP id k29so323853rvb.2
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2009 18:50:30 -0800 (PST)
In-Reply-To: <496D524E.6050706@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 13, 2009 at 6:47 PM, Li Zefan <lizf@cn.fujitsu.com> wrote:
>
> - we put extra burden on subsystem developers.

Better than putting extra burden on cgroup_lock() :-)

Anyway, if this turns out to be a common operation, we can provide
support for it in the framework rather than having each subsystem
duplicate the effort.

Paul
