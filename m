From: Bill Sommerfeld <wsommerfeld@google.com>
Subject: Re: Skipping past TCP lost packet in userspace
Date: Wed, 1 Jun 2011 09:57:30 -0700
Message-ID: <BANLkTikC+SUp-hvKZ-6nTf+VQQ=kFaFVcewek=1B6H500_4xkg@mail.gmail.com>
References: <4DE44218.4070306@krellan.com>
	<BANLkTinKORbHHZ7dAqfiFOg5rqB77DcJY8D7AxmP-xwhwmOgGg@mail.gmail.com>
	<4DE5F3E3.2080609@krellan.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Yuchung Cheng <ycheng@google.com>, netdev <netdev@vger.kernel.org>,
	jiyengar@fandm.edu
To: Josh Lehan <linux@krellan.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:37929 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751695Ab1FAQ5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 12:57:32 -0400
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id p51GvWuS009310
	for <netdev@vger.kernel.org>; Wed, 1 Jun 2011 09:57:32 -0700
Received: from qyk10 (qyk10.prod.google.com [10.241.83.138])
	by kpbe18.cbf.corp.google.com with ESMTP id p51GrA7T011772
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 1 Jun 2011 09:57:30 -0700
Received: by qyk10 with SMTP id 10so3786143qyk.11
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2011 09:57:30 -0700 (PDT)
In-Reply-To: <4DE5F3E3.2080609@krellan.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 1, 2011 at 01:10, Josh Lehan <linux@krellan.com> wrote:
> 2) If the out-of-order data is enough to be useful to the application,
> another ioctl() could be done, to ask the kernel to jump over the gap
> and deliver the data to the application.

this sounds like a different way to spell lseek(fd, gapsize, SEEK_CUR)

of course, allowing a subset of lseek for sockets could very well mess
with any code which (ab)uses lseek to guess the type of a random
descriptor.
