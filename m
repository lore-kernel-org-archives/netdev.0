From: cranium2003 <cranium2003@yahoo.com>
Subject: analysing ip_rcv code problems
Date: Fri, 10 Dec 2004 01:55:57 -0800 (PST)
Message-ID: <20041210095557.68648.qmail@web41407.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: net dev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hello,
                I know that in kernel 2.4 series,
function used to receive IP packets is ip_rcv. But i
am not getting where exactly IP header is removed that
is following lines from function ip_rcv can be used to
remove IP header                                      
                                                      
                                                      
                                                      
                                                      
                                                      
                                                      
                              if (!pskb_may_pull(skb,
sizeof(struct iphdr)))                                
                                                    
goto inhdr_error;                                     
                                                      
      iph = skb->nh.iph;                              
                                                      
                                                      
                                                      
                          ...                         
                                                      
                                        ...           
                                                      
                                                     
...                                                   
                                                      
              ...                                     
                                                      
                                             and also
following lines from same kernel is used to remove
header as IP
header length is 20 bytes then which function actually
does IP header removal.                               
                      if (!pskb_may_pull(skb,
iph->ihl*4))                                          
                                                    
goto inhdr_error;                                     
                                                      
                                                      
                                                      
                    iph = skb->nh.iph;                
                                                      
                                                      
                                                      
                                                      
Also why iph = skb->nh.iph statement is used twice in
function code ip_rcv.                                 
                                                      
                                                      
              regards,                                
                                                      
                            cranium.


		
__________________________________ 
Do you Yahoo!? 
Send holiday email and support a worthy cause. Do good. 
http://celebrity.mail.yahoo.com
