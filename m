From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [crash] BUG: unable to handle kernel NULL pointer dereference
 at 0000000000000370
Date: Mon, 21 Jul 2008 15:28:29 -0500
Message-ID: <4884F16D.7010709@lwfinger.net>
References: <20080721134506.GA27598@elte.hu> <20080721143023.GA32451@elte.hu> <20080721150446.GA17746@elte.hu> <20080721.082419.70392960.davem@davemloft.net> <4884D2F1.2030704@telenet.be> <20080721190646.GA19044@elte.hu> <4884DFEE.4060003@lwfinger.net> <20080721193425.GA29287@elte.hu> <4884E6E6.7010800@lwfinger.net> <alpine.LFD.1.10.0807211246280.31863@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Ian Schram <ischram-CNXmb7IdZIWZIoH1IeqzKA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, j@w1.fi
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LFD.1.10.0807211246280.31863-5CScLwifNT1QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Linus Torvalds wrote:
> 
> On Mon, 21 Jul 2008, Larry Finger wrote:
>> Yes, I'm chasing a distinct bug. The header for mine is
>>
>> Jul 21 12:19:37 larrylap kernel: kernel BUG at net/core/dev.c:1328!
> 
> Ok, that one is fixed now in my tree. Or at least it's turned into a 
> warning, so the machine should work.
> 
>> With an invalid opcode, mine is likely due to stack corruption.
> 
> No, invalid opcode is because we use the "ud2" instruction for BUG(), 
> which causes an invalid op exception. So any BUG[_ON]() will always cause 
> that on x86.

Thanks for the explanation.

With your latest tree, I do get the warning. Unfortunately, it still breaks my 
wireless and I still need to do the bisection. That is complicated by getting a 
kernel that won't build after the first try. I think I now have a workaround.

Larry
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
