From: Sachin Sant <sachinp@in.ibm.com>
Subject: [-next April 8] eHEA driver failure on powerpc
Date: Thu, 08 Apr 2010 17:25:51 +0530
Message-ID: <4BBDC447.3040901@in.ibm.com>
References: <20100408155113.ef8df30c.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, HERING2@de.ibm.com
To: linux-next@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100408155113.ef8df30c.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With today's next release, eHEA network interface on couple
of power6 boxes fails to initialize.

# modprobe ehea
IBM eHEA ethernet device driver (Release EHEA_0102)
  alloc irq_desc for 256 on node 0
  alloc kstat_irqs on node 0
irq: irq 590080 on host null mapped to virtual irq 256
ehea: Error in ehea_plpar_hcall_norets: opcode=26c ret=fffffffffffffffc arg1=8000000003000000 arg2=0 arg3=7000000000050400 arg4=fc9b0000 arg5=200 arg6=0 arg7=0
ehea: Error in ehea_reg_mr_section: register_rpage_mr failed
ehea: Error in ehea_reg_kernel_mr: registering mr failed
ehea: Error in ehea_setup_ports: creating MR failed
ehea 23c00200.lhea: setup_ports failed
ehea: probe of 23c00200.lhea failed with error -5
# lsmod
Module                  Size  Used by
ehea                   82002  0 
ipv6                  386130  24 
fuse                   89953  1 
loop                   20967  0 
dm_mod                105104  0 
sg                     40193  0 
sd_mod                 46334  3 
crc_t10dif              1619  1 sd_mod
ibmvscsic              36002  2 
scsi_transport_srp      8024  1 ibmvscsic
scsi_tgt               17581  1 scsi_transport_srp
scsi_mod              218761  5 sg,sd_mod,ibmvscsic,scsi_transport_srp,scsi_tgt
# ifconfig eth0
eth0: error fetching interface information: Device not found

Yesterday's next worked fine.

Thanks
-Sachin


-- 

---------------------------------
Sachin Sant
IBM Linux Technology Center
India Systems and Technology Labs
Bangalore, India
---------------------------------
