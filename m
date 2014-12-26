From: Alex Gartrell <agartrell@fb.com>
Subject: Re: [PATCH net-next 1/2] socket: Allow external sockets to use socket
 syscalls
Date: Fri, 26 Dec 2014 14:59:33 -0500
Message-ID: <549DBE25.3040302@fb.com>
References: <1419576624-8999-1-git-send-email-agartrell@fb.com> <1419576624-8999-2-git-send-email-agartrell@fb.com> <20141226195650.GF22149@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <herbert@gondor.apana.org.au>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:26383 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751259AbaLZUAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2014 15:00:15 -0500
In-Reply-To: <20141226195650.GF22149@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Al,

On 12/26/14 2:56 PM, Al Viro wrote:
> On Thu, Dec 25, 2014 at 10:50:23PM -0800, Alex Gartrell wrote:
>> Currently the "is-socket" test for a file compares the ops table pointer,
>> which is static and local to the socket.c.  Instead, this adds a flag for
>> private_data_is_socket.  This is an exceptionally long commit message for a
>> two-line patch.
>
> NAK.  Don't crap into struct file, please.
>

I don't disagree with your sentiment here.  Is the additional f_op 
approach less gross or do you have something else in mind?

Thanks,
-- 
Alex Gartrell <agartrell@fb.com>
