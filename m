From: "David S. Miller" <davem@redhat.com>
Subject: Re: Info: NAPI performance at "low" loads
Date: Wed, 18 Sep 2002 13:23:34 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020918.132334.102949210.davem@redhat.com>
References: <Pine.GSO.4.30.0209172053360.3686-100000@shell.cyberus.ca>
	<20020917.180014.07882539.davem@redhat.com>
	<m1hegnky2h.fsf@frodo.biederman.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, akpm@digeo.com, manfred@colorfullife.com,
   netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: ebiederm@xmission.com
In-Reply-To: <m1hegnky2h.fsf@frodo.biederman.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: ebiederm@xmission.com (Eric W. Biederman)
   Date: 18 Sep 2002 11:27:34 -0600

   "David S. Miller" <davem@redhat.com> writes:
   
   > {in,out}{b,w,l}() operations have a fixed timing, therefore his
   > results doesn't sound that far off.
   ????
   
   I don't see why they should be.  If it is a pci device the cost should
   the same as a pci memory I/O.  The bus packets are the same.  So things like
   increasing the pci bus speed should make it take less time.

The x86 processor has a well defined timing for executing inb
etc. instructions, the timing is fixed and is independant of the
speed of the PCI bus the device is on.
