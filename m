From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Fwd: [Bug 4774] e1000 driver works on UP, but not SMP x86_64
Date: Sat, 25 Jun 2005 22:22:18 +0400
Message-ID: <200506252222.18681.adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261234AbVFYSQW@vger.kernel.org>
To: David Lang <david.lang@digitalinsight.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

----------  Forwarded Message  ----------

Subject: [Bug 4774] e1000 driver works on UP, but not SMP x86_64
Date: Saturday 25 June 2005 21:55
From: bugme-daemon@kernel-bugs.osdl.org
To: adobriyan@gmail.com

http://bugzilla.kernel.org/show_bug.cgi?id=4774

------- Additional Comments From nacc@us.ibm.com  2005-06-25 10:55 -------
Hrm, that means that the corresponding PCI device (adapter->pdev->irq) is
requesting an IRQ greater than 224? Could you also attach the SMP .config? I
assume all you did was enabled SMP, ran make oldconfig & rebuilt? Do you know of
any kernel that *does* work?
