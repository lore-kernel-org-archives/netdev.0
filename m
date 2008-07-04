From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH 06/15] Introduce sysfs_sd_setattr and fix sysfs_chmod
Date: Fri, 04 Jul 2008 15:40:19 +0900
Message-ID: <486DC5D3.5050201@gmail.com>
References: <20080618170729.808539948@theryb.frec.bull.fr>	<m18wwmsqdv.fsf@frodo.ebiederm.org> <4869D314.5030403@gmail.com>	<m1ej6enep7.fsf@frodo.ebiederm.org> <486A0751.9080602@gmail.com>	<m1wsk5hjm0.fsf@frodo.ebiederm.org> <486AF4FA.8020805@gmail.com>	<m1ej6d9c2r.fsf@frodo.ebiederm.org> <486B060C.7030607@gmail.com>	<m14p78s02q.fsf@frodo.ebiederm.org> <486C4515.1070007@gmail.com>	<m1hcb7o8lv.fsf@frodo.ebiederm.org> <486CB051.5000507@fr.ibm.com>	<m14p77m9uy.fsf@frodo.ebiederm.org> <486CF71F.5090405@gmail.com>	<m1y74iiidz.fsf_-_@frodo.ebiederm.org>	<m1tzf6ihlz.fsf_-_@frodo.ebiederm.org>	<m1prpuihjb.fsf_-_@frodo.ebiederm.org>	<m1lk0iihhp.fsf_-_@frodo.ebiederm.org>	<m1hcb6ihfz.fsf_-_@frodo.ebiederm.org>	<m1d4luihea.fsf_-_@frodo.ebiederm.org> <m18wwiihbn.fsf_-_@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>,
	Linux Containers <containers@lists.osdl.org>,
	Benjamin Thery <benjamin.thery@bull.net>,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.231]:29927 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752293AbYGDGlM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2008 02:41:12 -0400
Received: by rv-out-0506.google.com with SMTP id k40so1392959rvb.1
        for <netdev@vger.kernel.org>; Thu, 03 Jul 2008 23:41:12 -0700 (PDT)
In-Reply-To: <m18wwiihbn.fsf_-_@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> Currently sysfs_chmod calls sys_setattr which in turn calls
> inode_change_ok which checks to see if it is ok for the current user
> space process to change tha attributes. Since sysfs_chmod_file has
> only kernel mode clients denying them permission if user space is the
> problem is completely inappropriate.
> 
> Therefore factor out sysfs_sd_setattr which does not call
> inode_change_ok and modify sysfs_chmod_file to call it.
> 
> In addition setting victim_sd->s_mode explicitly in sysfs_chmod_file
> is redundant so remove that as well.
> 
> Thanks to Tejun Heo <htejun@gmail.com>, and
> Daniel Lezcano <dlezcano@fr.ibm.com> for working on this
> and spotting this case.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Acked-by: Tejun Heo <tj@kernel.org>

-- 
tejun
