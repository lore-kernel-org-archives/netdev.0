From: Krishna Kumar <kumarkr@us.ibm.com>
Subject: Re: [5/6]: Dynamic neigh hash table growth
Date: Fri, 24 Sep 2004 13:11:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF75C0DF94.8BDAC480-ON88256F19.006C04FD-88256F19.006EF59D@us.ibm.com>
References: <20040923225127.10b0ef68.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=07BBE58ADFFF826D8f9e8a93df938690918c07BBE58ADFFF826D"
Cc: laforge@gnumonks.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040923225127.10b0ef68.davem@davemloft.net>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE58ADFFF826D8f9e8a93df938690918c07BBE58ADFFF826D
Content-type: text/plain; charset=US-ASCII





In neigh_hash_grow(), next need not be set to NULL.

thx,

- KK

> +   for (i = 0; i < old_entries; i++) {
> +      struct neighbour *n, *next;
> +
> +      next = NULL;
> +      for (n = old_hash[i]; n; n = next) {
> +         unsigned int hash_val = tbl->hash(n->primary_key, n->dev);
> +
> +         hash_val &= new_hash_mask;
> +         next = n->next;
> +
> +         n->next = new_hash[hash_val];
> +         new_hash[hash_val] = n;
> +      }
> +   }
--0__=07BBE58ADFFF826D8f9e8a93df938690918c07BBE58ADFFF826D
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p><tt>In neigh_hash_grow(), next need not be set to NULL.</tt><br>
<br>
<tt>thx,</tt><br>
<br>
<tt>- KK</tt><br>
<br>
<tt>&gt; + &nbsp; for (i = 0; i &lt; old_entries; i++) {<br>
&gt; + &nbsp; &nbsp; &nbsp;struct neighbour *n, *next;<br>
&gt; +<br>
&gt; + &nbsp; &nbsp; &nbsp;next = NULL;<br>
&gt; + &nbsp; &nbsp; &nbsp;for (n = old_hash[i]; n; n = next) {<br>
&gt; + &nbsp; &nbsp; &nbsp; &nbsp; unsigned int hash_val = tbl-&gt;hash(n-&gt;primary_key, n-&gt;dev);<br>
&gt; +<br>
&gt; + &nbsp; &nbsp; &nbsp; &nbsp; hash_val &amp;= new_hash_mask;<br>
&gt; + &nbsp; &nbsp; &nbsp; &nbsp; next = n-&gt;next;<br>
&gt; +<br>
&gt; + &nbsp; &nbsp; &nbsp; &nbsp; n-&gt;next = new_hash[hash_val];<br>
&gt; + &nbsp; &nbsp; &nbsp; &nbsp; new_hash[hash_val] = n;<br>
&gt; + &nbsp; &nbsp; &nbsp;}<br>
&gt; + &nbsp; }</tt></body></html>
--0__=07BBE58ADFFF826D8f9e8a93df938690918c07BBE58ADFFF826D--
