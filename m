From: "Robert Iakobashvili" <coroberti@gmail.com>
Subject: Binding a packet socket to interface down
Date: Thu, 22 Jun 2006 18:32:29 +0300
Message-ID: <7e63f56c0606220832i6b00f77bk352482c4a7c638cb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:63514 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751153AbWFVPcc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 11:32:32 -0400
Received: by nf-out-0910.google.com with SMTP id o60so275532nfa
        for <netdev@vger.kernel.org>; Thu, 22 Jun 2006 08:32:30 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

When packet socket (PF_SOCKET) is attempted in syscall bind () to the
network interface, which is down (no IF_UPP flag), packet_do_bind ()
sets error to the socket, but bind () does not fail.

When datagram, stream or raw socket fail to bind to some local
ip-port/ip, bind () fails.

Is this behavior of bind () for packet socket done deliberately, or
better to correct it so that bind will fail and return errno, e.g. ENODEV?
Thanks.

-- 
Sincerely,
------------------------------------------------------------------
Robert Iakobashvili, coroberti at gmail dot com
Navigare necesse est, vivere non est necesse.
------------------------------------------------------------------
