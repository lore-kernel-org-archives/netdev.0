From: Shirley Ma <xma@us.ibm.com>
Subject: Re: [PATCH]snmp6 64-bit counter support in proc.c
Date: Wed, 28 Jan 2004 12:09:15 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF80E3CE31.3A94BF63-ON87256E29.006EAFBA@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=08BBE4BADFFD292A8f9e8a93df938690918c08BBE4BADFFD292A"
Cc: Krishna Kumar <kumarkr@us.ibm.com>, kuznet@ms2.inr.ac.ru,
        mashirle@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=08BBE4BADFFD292A8f9e8a93df938690918c08BBE4BADFFD292A
Content-type: text/plain; charset=US-ASCII





> Perhaps there are some better ideas?

Yes. Dave, could we create a new interface to avoid the spin_lock?

Example 1:
modify write_seqlock(set_lock *s) to write_seqlock(seq_lock *s, int lock),
it will modify all calling routines.

Example 2:
write a new interface write_seqlock_percpu(), which gets rid of the
spin_lock, we can call by a different name, since there is no lock.

Thanks
Shirley Ma
IBM Linux Technology Center
15300 SW Koll Parkway
Beaverton, OR 97006-6063
Phone: (503) 578-7638
FAX:      (503) 578-3228
--0__=08BBE4BADFFD292A8f9e8a93df938690918c08BBE4BADFFD292A
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p><font face="Courier New">&gt; Perhaps there are some better ideas?</font><br>
<br>
Yes. Dave, could we create a new interface to avoid the spin_lock? <br>
<br>
Example 1:<br>
modify write_seqlock(set_lock *s) to write_seqlock(seq_lock *s, int lock), it will modify all calling routines.<br>
<br>
Example 2:<br>
write a new interface write_seqlock_percpu(), which gets rid of the spin_lock, we can call by a different name, since there is no lock. <br>
<br>
Thanks<br>
Shirley Ma<br>
IBM Linux Technology Center<br>
15300 SW Koll Parkway<br>
Beaverton, OR 97006-6063<br>
Phone: (503) 578-7638<br>
FAX:      (503) 578-3228<br>
</body></html>
--0__=08BBE4BADFFD292A8f9e8a93df938690918c08BBE4BADFFD292A--
