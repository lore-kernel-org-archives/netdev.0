From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: N_PPP_SYNC ldisc BUG: sleeping function called from invalid context
Date: Wed, 30 Sep 2009 22:28:18 +0200
Message-ID: <4AC3BF62.9020706@gmail.com>
References: <4AC37032.4030901@imap.cc> <20090930174704.796b24b9@lxorguk.ukuu.org.uk> <4AC3A986.4080808@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Alan Cox <alan@linux.intel.com>
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753521AbZI3U3V@vger.kernel.org>
In-Reply-To: <4AC3A986.4080808@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tilman Schmidt wrote, On 09/30/2009 08:55 PM:

> Alan Cox schrieb:
>>>  [<c026d39b>] tty_unthrottle+0x10/0x38
>>>  [<f8dcc31f>] ppp_sync_receive+0x168/0x170 [ppp_synctty]
>>>  [<f8fbb9ce>] handle_minor_recv+0x187/0x1cd [capi]
>>>  [<f8fbc19b>] capi_recv_message+0x1d9/0x24e [capi]
>> Really need to see the rest of the call trace to be sure
> 
> There wasn't more than what I posted. I had six of them, they looked all
> identical, and all of them ended after the kernel_thread_helper line. 
...
> Why then does mutex_lock() complain?


Maybe it doesn't matter here, but this: 

> INFO: lockdep is turned off.
suggests there was some lockdep issue/warning earlier.


Jarek P.
