From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [Bug 1491] New: No SADB_EXPIRE message sent when soft byte lifetime is reached]
Date: Tue, 4 Nov 2003 20:34:54 -0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031104223453.GC23401@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

One more...

----- Forwarded message from bugme-daemon@osdl.org -----

Date: Tue, 4 Nov 2003 09:26:37 -0800
From: bugme-daemon@osdl.org
Subject: [Bug 1491] New: No SADB_EXPIRE message sent when soft byte lifetime is reached
To: acme@conectiva.com.br

http://bugme.osdl.org/show_bug.cgi?id=1491

           Summary: No SADB_EXPIRE message sent when soft byte lifetime is
                    reached
    Kernel Version: 2.6.0-test4
            Status: NEW
          Severity: normal
             Owner: acme@conectiva.com.br
         Submitter: bbuesker@qualcomm.com


Distribution: Redhat 9
Hardware Environment: x86
Software Environment: ipsec-tools-0.2.2
Problem Description:
If byte lifetimes are used for IPsec security associations, the kernel does not
send an SADB_EXPIRE message to the key management daemon (racoon) when the soft
lifetime in terms of bytes is exceeded. Racoon only receives an SADB_EXPIRE
message when the hard lifetime is exceeded.

Steps to reproduce:
Reenable byte lifetimes in racoon. Set up a security policy requiring IPsec, and
with racoon running on two different machines, trigger the IKE negotiation by
sending a packet. Once the SA is established, continue sending packets until the
soft byte lifetime is exceeded. At this point, racoon should receive an
SADB_EXPIRE message indicating the soft lifetime has been exceeded. This message
is never sent by the kernel.

------- You are receiving this mail because: -------
You are the assignee for the bug, or are watching the assignee.

----- End forwarded message -----
