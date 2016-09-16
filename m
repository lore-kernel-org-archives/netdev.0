From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH v3] net: ip, diag -- Add diag interface for raw sockets
Date: Fri, 16 Sep 2016 22:39:27 +0300
Message-ID: <20160916193927.GB18116@uranus.lan>
References: <20160913171950.GC32643@uranus>
 <8260ff1f-6907-aed8-caae-68d63a4ad529@cumulusnetworks.com>
 <20160915202219.GB1867@uranus.lan>
 <f482796f-185e-a3b7-248c-20f1f39cb459@cumulusnetworks.com>
 <20160915210126.GC1867@uranus.lan>
 <1473979691.22679.55.camel@edumazet-glaptop3.roam.corp.google.com>
 <999f0ddb-82e4-ea07-b52a-59d08bc7816d@cumulusnetworks.com>
 <20160916070623.GD1867@uranus.lan>
 <20160916190000.GA18116@uranus.lan>
 <59e12627-7043-fd20-0d68-899ab43b0e71@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, avagin@openvz.org, stephen@networkplumber.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <59e12627-7043-fd20-0d68-899ab43b0e71@cumulusnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 16, 2016 at 01:30:28PM -0600, David Ahern wrote:
> > [root@pcs7 iproute2]# misc/ss -A raw
> > State      Recv-Q Send-Q                                Local Address:Port                                                 Peer Address:Port                
> > ESTAB      0      0                                         127.0.0.1:ipproto-255                                            127.0.0.10:ipproto-9090         
> > UNCONN     0      0                                        127.0.0.10:ipproto-255                                                     *:*                    
> > UNCONN     0      0                                                :::ipv6-icmp                                                      :::*                    
> > UNCONN     0      0                                                :::ipv6-icmp                                                      :::*                    
> > ESTAB      0      0                                               ::1:ipproto-255                                                   ::1:ipproto-9091         
> > 
> > so it get zapped out. Is there some other way to test it?
> > 
> 
> I'm guessing you passed IPPROTO_RAW (255) as the protocol to socket(). If you pass something
> else (IPPROTO_ICMP for example) it won't work.

True. To support IPPROTO_ICMP it need enhancement. I thought start with
plain _RAW first and then extend to support _ICMP.

	Cyrill
