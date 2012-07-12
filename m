From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next] r8169: Remove rtl_ocpdr_cond
Date: Fri, 13 Jul 2012 00:14:53 +0200
Message-ID: <20120712221453.GA1982@electric-eye.fr.zoreil.com>
References: <1342009916-1519-1-git-send-email-hayeswang@realtek.com> <20120711220045.GA8913@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120711220045.GA8913@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu <romieu@fr.zoreil.com> :
[...]
> I'll try again tomorrow evening.

W/o firmware does not seem to make a difference.

# ping -qf -l 4 -s 81 -c 60 10.0.3.1
PING 10.0.3.1 (10.0.3.1) 81(109) bytes of data.

--- 10.0.3.1 ping statistics ---
60 packets transmitted, 60 received, 0% packet loss, time 153ms
rtt min/avg/max/mdev = 0.047/0.064/0.117/0.016 ms, pipe 4, ipg/ewma 2.607/0.058 ms

# ping -qf -l 4 -s 82 -c 60 10.0.3.1                                                     
PING 10.0.3.1 (10.0.3.1) 82(110) bytes of data.

--- 10.0.3.1 ping statistics ---
60 packets transmitted, 60 received, 0% packet loss, time 3ms
rtt min/avg/max/mdev = 0.195/0.210/0.281/0.018 ms, pipe 4, ipg/ewma 0.057/0.205 ms

It would translate into a 127/128 cutoff after inclusion of the FCS.

Any idea ?

-- 
Ueimor
