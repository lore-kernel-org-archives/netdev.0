From: James Morris <jmorris@namei.org>
Subject: Re: [RFC] Allow LSM to use IP address/port number. (was Re: [PATCH
 1/1] Add post accept()/recvmsg() hooks.) (fwd)
Date: Mon, 9 Jul 2007 15:24:57 -0400 (EDT)
Message-ID: <Line.LNX.4.64.0707091524380.7967@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.sea5.speakeasy.net ([69.17.117.5]:40890 "EHLO
	mail3.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754113AbXGITY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 15:24:59 -0400
Received: from dsl092-066-197.bos1.dsl.speakeasy.net (HELO d.namei) ([66.92.66.197])
          (envelope-sender <jmorris@namei.org>)
          by mail3.sea5.speakeasy.net (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 9 Jul 2007 19:24:58 -0000
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(original cc list has wrong netdev addr)

---------- Forwarded message ----------
Date: Mon, 9 Jul 2007 15:17:28 -0400 (EDT)
From: James Morris <jmorris@namei.org>
To: Tetsuo Handa <from-netdev@i-love.sakura.ne.jp>
Cc: linux-netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
    chrisw@sous-sol.org
Subject: Re: [RFC] Allow LSM to use IP address/port number. (was Re: [PATCH 1/1]
     Add post accept()/recvmsg() hooks.)

On Mon, 9 Jul 2007, Tetsuo Handa wrote:

> Hello.
> 
> This thread is from http://marc.info/?t=118346457000005&r=1&w=2 .
> 
> I want to use tcp_wrapper-like filtering using LSM.

The appropriate way to do this would be via netfilter queuing to 
userspace, as already suggested by Paul Moore.


-- 
James Morris
<jmorris@namei.org>
-
To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
