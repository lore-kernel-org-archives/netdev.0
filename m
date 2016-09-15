From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] net: ip, diag -- Add diag interface for raw sockets
Date: Thu, 15 Sep 2016 13:36:08 -0700
Message-ID: <1473971768.22679.53.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160913171950.GC32643@uranus>
         <8260ff1f-6907-aed8-caae-68d63a4ad529@cumulusnetworks.com>
         <20160915202219.GB1867@uranus.lan>
         <cc67e1b1-ad0c-f0f6-4b4d-2eab80e940da@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, avagin@openvz.org, stephen@networkplumber.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cc67e1b1-ad0c-f0f6-4b4d-2eab80e940da@cumulusnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-09-15 at 14:25 -0600, David Ahern wrote:
> On 9/15/16 2:22 PM, Cyrill Gorcunov wrote:
> >> ss -K is not working. Socket lookup fails to find a match due to a protocol mismatch.
> >>
> >> haven't had time to track down why there is a mismatch since the kill uses the socket returned
> >> from the dump. Won't have time to come back to this until early next week.
> > 
> > Have you ran iproute2 patched? I just ran ss -K and all sockets get closed
> > (including raw ones), which actually kicked me off the testing machine sshd :/
> 
> yes.
> 

And CONFIG_INET_DIAG_DESTROY is also set in your .config ?
