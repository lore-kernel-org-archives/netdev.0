From: David Lang <david.lang@digitalinsight.com>
Subject: Re: The ultimate TOE design
Date: Fri, 17 Sep 2004 13:36:14 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.60.0409171333510.24478@dlang.diginsite.com>
References: <4148991B.9050200@pobox.com>
 <OF8783A4F6.D566336C-ON88256F10.006E51CE-88256F10.006EDA93@us.ibm.com><311601c90409162346184649eb@mail.gmail.com>
 <200409172027.i8HKRVwY005444@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Eric Mudama <edmudama@gmail.com>, David Stevens <dlstevens@us.ibm.com>,
        Netdev <netdev@oss.sgi.com>, leonid.grossman@s2io.com,
        Linux Kernel
	 <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Valdis.Kletnieks@vt.edu
In-Reply-To: <200409172027.i8HKRVwY005444@turing-police.cc.vt.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

actually the sector based access that is made to modern drives is a very 
primitive filesystem. if you go back to the days of the MFM and RLL drives 
you had the computer sending the raw bitstreams to the drives, but with 
SCSI and IDE this stopped and you instead a higher level logical block to 
the drive and it deals with the details of getting it to and from the 
platter.

David Lang

On Fri, 17 Sep 2004 Valdis.Kletnieks@vt.edu wrote:

> Date: Fri, 17 Sep 2004 16:27:31 -0400
> From: Valdis.Kletnieks@vt.edu
> To: Eric Mudama <edmudama@gmail.com>
> Cc: David Stevens <dlstevens@us.ibm.com>, Netdev <netdev@oss.sgi.com>,
>     leonid.grossman@s2io.com, Linux Kernel <linux-kernel@vger.kernel.org>
> Subject: Re: The ultimate TOE design 
> 
> On Fri, 17 Sep 2004 00:46:59 MDT, Eric Mudama said:
>> On Wed, 15 Sep 2004 14:11:04 -0600, David Stevens <dlstevens@us.ibm.com> wrot
> e:
>>> Why don't we off-load filesystems to disks instead?
>>
>> Disks have had file systems on them since close to the beginning...
>
> No, he means "offload the processing of the filesystem to the disk itself".
>
> IBM's MVS  systems basically did that - it used the disk's "Search Key" I/O
> opcodes to basically get the equivalent of doing namei() out on the disk itself
> (it did this for system catalog and PDS directory searches from the beginning,
> and added 'indexed VTOC' support in the mid-80s).  So you'd send out a CCW
> (channel command word) stream that basically said "Find me the dataset
> USER3.ACCTING.TESTJOBS", and when the I/O completed, you'd have the DSCB (the
> moral equiv of an inode) ready to go.
>
>

-- 
There are two ways of constructing a software design. One way is to make it so simple that there are obviously no deficiencies. And the other way is to make it so complicated that there are no obvious deficiencies.
  -- C.A.R. Hoare
