From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH][12/37] Clean up duplicate includes in drivers/net/
Date: Sat, 21 Jul 2007 12:50:26 -0400
Message-ID: <46A23952.6060207@redhat.com>
References: <200707211702.46375.jesper.juhl@gmail.com>	
	<46A236FC.2080300@redhat.com>
	<9a8748490707210948k468f8f32k718d84279aa56ce9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: info@netxen.com, Luke Yang <luke.yang@analog.com>,
	Judy Fischbach <jfisch@cs.pdx.edu>, Patrick McHardy <kaber@coreworks.de>,
	bonding-devel@lists.sourceforge.net,
	Bryan Wu <bryan.wu@analog.com>, kong.lai@tundra.com,
	Jay Vosburgh <fubar@us.ibm.com>,
	James Morris <jmorris@namei.org>, linuxppc-embedded@ozlabs.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Alex V Lasso <a_villacis@palosanto.com>,
	Ulrich Kunitz <kune@deine-taler.de>,
	Chad Tindel <ctindel@users.sourceforge.net>,
	Amit S Kale <amitkale@netxen.com>, Jay Cliburn <jcliburn@gmail.com>,
	Samuel Ortiz <samuel@sortiz.org>, Daniel Drake <dsd@gentoo.org>,
	Brian Pugh <bpugh@cs.pdx.edu>, viro@ftp.linux.org.uk,
	alexandre.bounine@tundra.com,
	Pantelis Antoniou <panto@intracom.gr>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Ralf Baechle <ralf@linux-mips.or
To: Jesper Juhl <jesper.juhl@gmail.com>
Return-path: <linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <9a8748490707210948k468f8f32k718d84279aa56ce9@mail.gmail.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Jesper Juhl wrote:
> On 21/07/07, Chris Snook <csnook@redhat.com> wrote:
>> Jesper Juhl wrote:
>> > Hi,
>> >
>> > This patch cleans up duplicate includes in
>> >        drivers/net/
>> >
>> >
>> > Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
>> > ---
>> >
>> > diff --git a/drivers/net/atl1/atl1_main.c 
>> b/drivers/net/atl1/atl1_main.c
>> > index fd1e156..4a18b88 100644
>> > --- a/drivers/net/atl1/atl1_main.c
>> > +++ b/drivers/net/atl1/atl1_main.c
>> > @@ -75,7 +75,6 @@
>> >  #include <linux/compiler.h>
>> >  #include <linux/delay.h>
>> >  #include <linux/mii.h>
>> > -#include <linux/interrupt.h>
>> >  #include <net/checksum.h>
>> >
>> >  #include <asm/atomic.h>
>>
>> Define "duplicate".  I ask because this patch just got posted a few 
>> days ago:
>>
> 
> duplicate == present more than once in the same source file.
> Did you try looking at the includes in the source file the patch modifies?

Nope!  Mea Culpa.

	-- Chris
