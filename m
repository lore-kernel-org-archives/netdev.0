From: Renato Westphal <renatowestphal@gmail.com>
Subject: Move interface across network namespaces
Date: Wed, 10 Aug 2011 21:31:39 -0300
Message-ID: <CAChaegkomwjL0X7HnfLi1XH26jDKOL6fCgjfms67cjjU4gRXPg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:60196 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752019Ab1HKAbk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2011 20:31:40 -0400
Received: by vws1 with SMTP id 1so1320669vws.19
        for <netdev@vger.kernel.org>; Wed, 10 Aug 2011 17:31:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have two questions regarding the process of moving a network
interface across different network namespaces:

* When I move an interface, all the virtual interfaces attached to it
are deleted. Is there any reason for such odd behavior? I would like
to move some network interfaces and keep the attached vlans untouched.

* The target network namespace sends a RTM_NEWLINK netlink message
when an interface is moved to it. In the other hand, the source
network namespace doesn't sends a RTM_DELLINK message when an
interface is moved from it. This is very annoying because user space
applications (such as zebra) can't detect some interface moving
operations and then get into an inconsistent state. Anyone knows if
there's a workaround for this?

Any help would be appreciated.

Best Regards,
Renato.

-- 
Renato Westphal
