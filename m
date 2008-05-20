From: "Rune Torgersen" <runet@innovsys.com>
Subject: RE: Oops in fs_enet driver with preempt-rt
Date: Tue, 20 May 2008 11:31:08 -0500
Message-ID: <DCEAAC0833DD314AB0B58112AD99B93B046E73EC@ismail.innsys.innovsys.com>
References: <DCEAAC0833DD314AB0B58112AD99B93B046E728C@ismail.innsys.innovsys.com>
	<DCEAAC0833DD314AB0B58112AD99B93B046E72C3@ismail.innsys.innovsys.com>
	<4832F139.1020502@freescale.com>
	<DCEAAC0833DD314AB0B58112AD99B93B046E73C6@ismail.innsys.innovsys.com>
	<4832FA80.7060807@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Scott Wood" <scottwood@freescale.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-class: urn:content-classes:message
In-Reply-To: <4832FA80.7060807@freescale.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Scott Wood wrote:
> Rune Torgersen wrote:
>> Hmm.... ttyCPM1 output seems to be kinda garbled... Any ideas?
>> Incomplete locking between printk and userland use of ttyCPM1 as
>> console?
> 
> s/incomplete/nonexistent/ :-P
> 
> Try acquiring port->lock in cpm_uart_console_write.
> 
> -Scott

That worked. Console output is sane again.
