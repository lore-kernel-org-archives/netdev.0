From: Dave Jones <davej@suse.de>
Subject: hook 0 already set.
Date: Thu, 10 Jul 2003 17:38:31 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030710173831.B31068@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

My 2 NIC proxy arp firewall started spitting these out in 2.5..

Jul  9 22:17:52 equinox kernel: nf_hook: hook 0 already set.
Jul  9 22:17:52 equinox kernel: skb: pf=0 (unowned) dev=eth0 len=46

There's no real pattern that I can observe to trigger them, although...

(root@equinox:davej)# grep "hook 0 already set" /var/log/syslog.0 | wc  -l
   7660

It does seem to happen quite a lot in this particular setup.

        Dave

-- 
| Dave Jones.        http://www.codemonkey.org.uk
| SuSE Labs
