From: Vladislav Bolkhovitin <vst@vlnb.net>
Subject: Re: [PATCH][RFC 21/23]: iSCSI target driver
Date: Fri, 12 Dec 2008 22:26:22 +0300
Message-ID: <4942BADE.5010907@vlnb.net>
References: <494009D7.4020602@vlnb.net>  <49401205.8010207@vlnb.net> <1229036109.4153.585.camel@haakon2.linux-iscsi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-scsi@vger.kernel.org,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Jeff Garzik <jeff@garzik.org>,
	Boaz Harrosh <bharrosh@panasas.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, scst-devel@lists.sourceforge.net,
	Bart Van Assche <bart.vanassche@gmail.com>,
	netdev@vger.kernel.org, Rafiu Fakunle <rafiu@openfiler.com>
To: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753918AbYLLT0Z@vger.kernel.org>
In-Reply-To: <1229036109.4153.585.camel@haakon2.linux-iscsi.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nicholas A. Bellinger wrote:
> On Wed, 2008-12-10 at 22:01 +0300, Vladislav Bolkhovitin wrote:
>> This patch contains iSCSI-SCST target driver. This driver is a heavily 
>> modified forked with all respects IET 
>> (http://iscsitarget.sourceforge.net). Modifications were aimed to make a 
>> clearer, more reviewable and maintainable code as well as to fix many 
>> problems and make many improvements. See 
>> http://scst.sourceforge.net/target_iscsi.html for more details.
>>
>> It has split user/kernel space architecture, where all management, 
>> sessions creation, parameters negotiation, etc. made in user space and 
>> data are transferred in the kernel space. Such architecture for iSCSI 
>> processing was many times acknowledged as the right one. Particularly, 
>> in-kernel iSCSI initiator (open-iscsi) has such architecture.
>>
> 
> Just as with the Open/iSCSI Initiator, IMHO I believe the split
> architecture design is difficult both to improve, debug and maintain,
> and provides *ZERO* additional benefit in the context of traditional
> iSCSI target mode for doing login and connection/session setup in
> userspace.
> 
> Also, I appericate that you spent alot of time porting over IET code to
> your engine, but during our previous discussion you did not seem
> terribly interested in validation against core-iscsi-dv
> (http://linux-iscsi.org/index.php/Core-iscsi-dv) to test RFC-3720
> interopt and stability.  Because the Core-iSCSI Initiator supports every
> possible parameter combination up to ErrorRecoveryLevel=0 defined in
> RFC-3720, the Core-iSCSI-Dv tests can run badblocks (or any too) to
> check data integrity for *EVERY* possible traditional iSCSI key
> combination and functionality for your iSCSI-SCST work, and any type of
> serious iSCSI-SCST production deployments.

The fact that nobody so far cared to do all those complicated and time 
consuming rather academic tests doesn't mean that iSCSI-SCST won't pass 
them. IET/iSCSI-SCST have been used for a long time in very different 
setups, including xBSD and Solaris initiators on non-x86 architectures, 
without any problems.

Vlad
