From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: [Question] SMP for TCP/IP Stack
Date: Tue, 24 Sep 2002 22:35:01 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020924223501.K2531@redhat.com>
References: <20020925112731.A19934@toad.postech.ac.kr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Hyochang Nam <cannon@postech.ac.kr>
Content-Disposition: inline
In-Reply-To: <20020925112731.A19934@toad.postech.ac.kr>; from cannon@postech.ac.kr on Wed, Sep 25, 2002 at 11:27:31AM +0900
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Have you made sure each nic is on a separate interrrupt and that those 
interrupts are bound to different cpus?

		-ben

On Wed, Sep 25, 2002 at 11:27:31AM +0900, Hyochang Nam wrote:
> 
> Can Linux Kernel 2.4.X handle two IP Packets at the same time
> in a SMP machine which has two CPUs?
> I have a SMP machine which equips two Intel Xeon CPUs and two
> Intel Gigabit Network Cards. When I sent small IP Packets
> to the machine, most of packets are dropped. When I watch 
> CPU utlization with TOP program, only one CPU shows high value
> but the other shows much low value, ie. 10% CPU utlization.
> My test shows current IP Stack in Linux Kernel cannot provide 
> SMP Processing properly. But, some articles said Linux Kernel 2.4
> gives true SMP processing. What do you think my problem is?
> 
> Best regards,
> 
> Hyochang Nam
> 

-- 
GMS rules.
