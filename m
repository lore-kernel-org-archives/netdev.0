From: Bodo Eggert <7eggert@gmx.de>
Subject: Bad escriptions in Kconfig
Date: Mon, 31 Dec 2007 13:26:32 +0100 (CET)
Message-ID: <alpine.LSU.0.999.0712311313050.3761@be1.lrz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: linux-scsi@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In some of the Kconfig files, the options are not adequately decribed. I 
collected a few of the bad descriptions I found:


---
Lowlevel video output switch controls (VIDEO_OUTPUT_CONTROL) [M/n/y/?] (NEW) ?

This framework adds support for low-level control of the video
output switch.
---

- What is THE video output switch and why would I need low level control?

- Frameworks should be auto-selected like libraries, shouldn't they?

- WTF is this a module?


-------------
---
Auxiliary Display support (AUXDISPLAY) [N/y/?] (NEW) ?

Say Y here to get to see options for auxiliary display drivers.
This option alone does not add any kernel code.
---

- If I knw what an axilary display was, I would not read this help text!

- After digging some time, I discovered that all Auxdisplays are parallel 
  port devices.
  Rename to "Parallel port display device support"?


-------------
---
Transformation user configuration interface (XFRM_USER) [N/m/y/?] (NEW)
  
Support for Transformation(XFRM) user configuration interface
like IPsec used by native Linux tools.

If unsure, say Y.
---

- I'm not sure if these words combine to a sentence.
- I can't tell if IPSEC is the only user or if I'd break other parts by not 
  saying 'Y'. OTOH, I don't want to bloat my kernel ...
- What's a native linux tool?

  
-------------
---
SCSI target support (SCSI_TGT) [N/m/y/?] (NEW) ?

If you want to use SCSI target mode drivers enable this option.
If you choose M, the module will be called scsi_tgt.
---

What TF is a SCSI target mode, what is a target mode driver?

-- 
I'm a member of DNA (National Assocciation of Dyslexics).
	-- Storm in <5Z4Z7.52353$4x4.6445347@news2-win.server.ntlworld.com>
