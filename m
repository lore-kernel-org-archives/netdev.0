From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: fix "entering disabled state" logging
Date: Tue, 06 Mar 2012 14:33:55 -0500 (EST)
Message-ID: <20120306.143355.1005128775927562130.davem@davemloft.net>
References: <20120306142219.31783.30201.stgit@localhost.localdomain>
	<4F56208E.2090801@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: paulius.zaleckas@gmail.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <4F56208E.2090801@gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Date: Tue, 06 Mar 2012 16:34:54 +0200

> On 03/06/2012 04:22 PM, Paulius Zaleckas wrote:
>> Now we have:
>> eth0: link down
>> br0: port 1(eth0) entering forwarding state
>>
>> State should be logged *after* it was changed, not before.
> 
> The funny thing is that it was introduced:
> 2010-05-16 	stephen hemminger
> bridge: change console message interface
> 28a16c97963d3bc36a2c192859f6d8025ef2967a
> 
> and no one noticed since then :D

No, someone noticed, you're not the first person to propose this
patch and it was rejected just like your's will be.
