From: Andy Furniss <andy.furniss@dsl.pipex.com>
Subject: Re: Linux v2.6.16-rc6
Date: Sun, 09 Apr 2006 13:08:50 +0100
Message-ID: <4438F952.5040802@dsl.pipex.com>
References: <Pine.LNX.4.64.0603111551330.18022@g5.osdl.org>	<6bffcb0e0603111751i1ed30794s@mail.gmail.com> <20060311.183904.71244086.davem@davemloft.net>
Reply-To: andy.furniss@dsl.pipex.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: michal.k.k.piotrowski@gmail.com, torvalds@osdl.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750738AbWDIMIw@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060311.183904.71244086.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> From: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
> Date: Sun, 12 Mar 2006 02:51:40 +0100
> 
> 
>>I have noticed this warnings
>>TCP: Treason uncloaked! Peer 82.113.55.2:11759/50967 shrinks window
>>148470938:148470943. Repaired.
>>TCP: Treason uncloaked! Peer 82.113.55.2:11759/50967 shrinks window
>>148470938:148470943. Repaired.
>>TCP: Treason uncloaked! Peer 82.113.55.2:11759/59768 shrinks window
>>1124211698:1124211703. Repaired.
>>TCP: Treason uncloaked! Peer 82.113.55.2:11759/59768 shrinks window
>>1124211698:1124211703. Repaired.
>>
>>It maybe problem with ktorrent.
> 
> 
> It is a problem with the remote TCP implementation, it is
> illegally advertising a smaller window that it previously
> did.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

Packeteer manipulates window for shaping. I probably misread/read wrong 
RFC on this but I thought it didn't break any MUST NOTs.

I assume Linux + SFQ reordering packets during window growth would not 
trigger it.

Andy.
