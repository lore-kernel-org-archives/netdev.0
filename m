From: Tejun Heo <htejun@gmail.com>
Subject: Re: New laptop - problems with linux
Date: Thu, 09 Nov 2006 13:38:46 +0900
Message-ID: <4552B0D6.5040100@gmail.com>
References: <4551EC86.5010600@seclark.us>	<4551F3A6.8040807@gmail.com>	<4551F5B7.1050709@seclark.us>	<20061108182658.GA21154@electric-eye.fr.zoreil.com>	<45523289.2010002@seclark.us> <20061108122649.2f79ec1f@freekitty> <45523F3F.8010806@seclark.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Jiri Slaby <jirislaby@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:26206 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1423860AbWKIEi4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Nov 2006 23:38:56 -0500
Received: by ug-out-1314.google.com with SMTP id m3so115577ugc
        for <netdev@vger.kernel.org>; Wed, 08 Nov 2006 20:38:55 -0800 (PST)
To: Stephen.Clark@seclark.us
In-Reply-To: <45523F3F.8010806@seclark.us>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Clark wrote:
> Thanks I have that working - I am now struggling with the disk being
> slower than molasses ( high priority, 1.xx mb/sec  )

Add 'combined_mode=libata' to kernel parameter and see what happens. 
This should make libata take care of all ATA ports and your harddisks 
will appear as /dev/sda and sdb, your cdrom /dev/sr0.  So, you might 
need to adjust root= parameter too.

-- 
tejun
