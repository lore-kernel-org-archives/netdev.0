From: Paolo Pumilia <paolo.pumilia@acm.org>
Subject: ioport.h fixed in 2.2.22
Date: Sun, 10 Nov 2002 14:00:19 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021110130019.GA14897@wigner.cstc.lan>
Reply-To: paolo.pumilia@inwind.it
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="jI8keyz6grp/JLjh"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

In order to compile 3.1.28 pcmcia modules (package pcmcia-cs-3.1.28), 
commenting out lines referring to compatibility to kernel 2.4
in file: include/linux/ioport.h, in kernel-source 2.2.22 has been
required, 
Here enclosed is my fixed file. 

Being just a newbie, i hope it has been the right action to take. 

Thank you 

--
Paolo Pumilia
AICA- OpenSource workgroup 
AICA OpenSource WorkGroup Coordinator 
Website: http//www.linfe.it/AICA-OpenSource


--jI8keyz6grp/JLjh
Content-Type: text/x-chdr; charset=us-ascii
Content-Disposition: attachment; filename="v2.2.22-fixed-ioport.h"

/* file:  /home/src/kernel-source-2.2.22/include/linux/ioport.h
 * modified in order to allow pcmcia modules compilation 
 * Paolo Pumilia, nov 10, 2002 - paolo.pumilia@acm.org
 */ 

/*
 * portio.h	Definitions of routines for detecting, reserving and
 *		allocating system resources.
 *
 * Version:	0.01	8/30/93
 *
 * Author:	Donald Becker (becker@super.org)
 */

#ifndef _LINUX_PORTIO_H
#define _LINUX_PORTIO_H

#define HAVE_PORTRESERVE
/*
 * Call check_region() before probing for your hardware.
 * Once you have found you hardware, register it with request_region().
 * If you unload the driver, use release_region to free ports.
 */
extern void reserve_setup(char *str, int *ints);
extern int check_region(unsigned long from, unsigned long extent);
extern void request_region(unsigned long from, unsigned long extent,const char *name);
extern void release_region(unsigned long from, unsigned long extent);
extern int get_ioport_list(char *);

#ifdef __sparc__
extern unsigned long occupy_region(unsigned long base, unsigned long end,
				   unsigned long num, unsigned int align,
				   const char *name);
#endif

#define HAVE_AUTOIRQ
extern void autoirq_setup(int waittime);
extern int autoirq_report(int waittime);

/*
 * for compatibility with 2.4
 */

/* commented out, in order to allow pcmcia modules compilation 
 * Paolo Pumilia, nov 10, 2002 - paolo.pumilia@acm.org
 *
 * extern inline int check_mem_region(unsigned long from, unsigned long extent)
 * {
 * 	return 0;
 * }
 * 
 * extern inline void request_mem_region(unsigned long from, unsigned long extent,const char *name)
 * {
 * }
 * 
 * extern inline void release_mem_region(unsigned long from, unsigned long extent)
 * {
 * }
 */ 

#endif	/* _LINUX_PORTIO_H */

--jI8keyz6grp/JLjh--
