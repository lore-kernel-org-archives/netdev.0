From: Mauro Carvalho Chehab <mchehab@redhat.com>
Subject: Re: [PATCH 00/34] Make kernel build deterministic
Date: Tue, 05 Apr 2011 15:29:19 -0300
Message-ID: <4D9B5F7F.6090609@redhat.com>
References: <1302015561-21047-1-git-send-email-mmarek@suse.cz>	
	<20110405154918.GA31337@suse.de>
	<1302027412.2924.7.camel@mulgrave.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: anil_ravindranath@pmc-sierra.com, benh@kernel.crashing.org, x86@kernel.org,
	mac@melware.de, aacraid@adaptec.com,
	linux-mtd@lists.infradead.org, allan.stephens@windriver.com,
	hpa@zytor.com, netdev@vger.kernel.org, t.sailer@alumni.ethz.ch,
	gwingerde@gmail.com, IvDoorn@gmail.com, elf@buici.com,
	cluster-devel@redhat.com, ccaulfie@redhat.com, mingo@redhat.com,
	dougthompson@xmission.com, linux-media@vger.kernel.org,
	jon.maloy@ericsson.com, arnaud.giersch@free.fr,
	linux-kbuild@vger.kernel.org, teigland@redhat.com,
	tony.olech@elandigitalsystems.com, apw@canonical.com,
	linux-hams@vger.kernel.org, tglx@linutronix.de,
	swhiteho@redhat.com, linux-arm-kernel@lists.infradead.org,
	linux-edac@vger.kernel.org, Michal Marek <mmarek@suse.cz>,
	linux-scsi@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	Greg KH <gregkh@suse.de>, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org,
To: James Bottomley <James.Bottomley@suse.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1302027412.2924.7.camel@mulgrave.site>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Em 05-04-2011 15:16, James Bottomley escreveu:
> On Tue, 2011-04-05 at 08:49 -0700, Greg KH wrote:
>> On Tue, Apr 05, 2011 at 04:58:47PM +0200, Michal Marek wrote:
>>>
>>> Hi,
>>>
>>> this series makes it possible to build bit-identical kernel image and
>>> modules from identical sources. Of course the build is already
>>> deterministic in terms of behavior of the code, but the various
>>> timestamps embedded in the object files make it hard to compare two
>>> builds, for instance to verify that a makefile cleanup didn't
>>> accidentally change something. A prime example is /proc/config.gz, which
>>> has both a timestamp in the gzip header and a timestamp in the payload
>>> data. With this series applied, a script like this will produce
>>> identical kernels each time:
>>
>> Very nice stuff.  Do you want to take the individual patches through one
>> of your trees, or do you mind if the subsystem maintainers take them
>> through theirs?
> 
> I'm happy for this to go through a single tree.

Me too.

With respect to the patches I was c/c (patches 13, 14, 31):

Acked-by: Mauro Carvalho Chehab <mchehab@redhat.com>

Thanks,
Mauro.
